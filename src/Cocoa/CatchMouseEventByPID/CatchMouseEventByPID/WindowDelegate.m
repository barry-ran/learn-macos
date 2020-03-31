//
//  WindowDelegate.m
//  CatchMouseEvent
//
//  Created by barry on 2020/3/1.
//  Copyright © 2020 barry. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "WindowDelegate.h"

@interface WindowDelegate ()

@property(weak) IBOutlet NSTextField* text;

@end

// static到成员函数的转换
static CGEventRef callback(CGEventTapProxy proxy,
                           CGEventType type,
                           CGEventRef event,
                           void* refcon) {
    WindowDelegate* p = (__bridge WindowDelegate*)(refcon);
    
    if (p) {
        return [p callback:proxy
                      type:type
                     event:event];
    }
    return NULL;
}

@implementation WindowDelegate
{
    CFMachPortRef eventTap_;
    CFRunLoopSourceRef source_;
}

- (void)dealloc {
    if (source_) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source_, kCFRunLoopCommonModes);
        CFRelease(source_);
    }
    
    if (eventTap_) {
        // 需要手动关闭，直接CFRelease并不会关闭
        CGEventTapEnable(eventTap_, false);
        CFRelease(eventTap_);
    }
}

- (IBAction)catchBtnClick:(id)sender
{
    NSLog(@"catchBtnClick");
    int pid = [pidField intValue];
    NSLog(@"pid is %d", pid);
    if (0 == pid) {
        return;
    }
    // 要捕获的事件
    CGEventMask mask = CGEventMaskBit(kCGEventLeftMouseDown) | CGEventMaskBit(kCGEventLeftMouseUp) |
    CGEventMaskBit(kCGEventFlagsChanged);
    
    // CGEventTapCreateForPSN已经过时，它的参数processSerialNumber没有办法获取到
    // CGEventTapCreateForPid是用来代替CGEventTapCreateForPSN的，唯一的不同就是进程用pid表示
    // 确实可以监听某个进程的事件，但是如果这个进程监听了全局事件，那么你也会收到
    eventTap_ = CGEventTapCreateForPid(pid,                      // 捕获点
                                 kCGHeadInsertEventTap,         // 插入位置
                                 kCGEventTapOptionDefault,      // 捕获方式
                                 mask,                          // 捕获事件
                                 callback,                      // 回调函数
                                 (__bridge void*)(self));       // 自定义数据
    if (eventTap_ == NULL) {
        NSLog(@"eventTap_ is null");
        return;
    }
    source_ = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap_, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source_, kCFRunLoopCommonModes);
    
    // 默认是启用监听的，这里不设置也可以
    CGEventTapEnable(eventTap_, true);
}

- (IBAction)unCatchBtnClick:(id)sender
{
    NSLog(@"unCatchBtnClick");
    if (eventTap_ == NULL) {
        NSLog(@"eventTap_ == NULL");
        return;
    }
    if (source_) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source_, kCFRunLoopCommonModes);
        CFRelease(source_);
        source_ = NULL;
    }
    CGEventTapEnable(eventTap_, false);
    CFRelease(eventTap_);
    eventTap_ = NULL;
}

- (CGEventRef)callback:(CGEventTapProxy)proxy
                  type:(CGEventType)type
                 event:(CGEventRef)event {
    switch (type) {
        case kCGEventTapDisabledByTimeout:
            // 如果回调的处理时间过长，监听会被置为失效，并收到这个事件
            NSLog(@"kCGEventTapDisabledByTimeout");
            //CGEventTapEnable(eventTap_, true);
            break;
        case kCGEventLeftMouseDown:
        {
            NSLog(@"kCGEventLeftMouseDown*******************");
            
            Boolean ignoreEvent = YES;
            
            // 区分事件源
            Boolean fromApi = NO;
            // 可以直接获取事件的SourceStateID
            // 使用kCGEventSourceStatePrivate获取到的值是一个随机数，并不是-1，
            // 所以应该判断是否是kCGEventSourceStateHIDSystemState和kCGEventSourceStateCombinedSessionState
            int64_t sourceStateID = CGEventGetIntegerValueField(event, kCGEventSourceStateID);
            NSLog(@"sourceStateID: %lld", sourceStateID);
            if ((kCGEventSourceStateHIDSystemState != sourceStateID)
                && (kCGEventSourceStateCombinedSessionState != sourceStateID)) {
                fromApi = YES;
            }
            
            // 获取鼠标下窗口标题(mac中有两个坐标系，如果用CGEventGetLocation获取的坐标不能用来windowNumberAtPoint)
            CGPoint location = CGEventGetUnflippedLocation(event);
            NSLog(@"location: (%f,%f)", location.x, location.y);
            
            int64_t windowNumber = CGEventGetIntegerValueField(event, kCGMouseEventWindowUnderMousePointer);
            int64_t windowNumber2 = CGEventGetIntegerValueField(event, kCGMouseEventWindowUnderMousePointerThatCanHandleThisEvent);
            
            // 在同一个进程也可以根据目标窗口number精确过滤
            if (5032 == windowNumber) {
                ignoreEvent = NO;
            }
            
            CGWindowID windowID = (CGWindowID)windowNumber;
            
            NSLog(@"window id: %lld,%lld", windowNumber, windowNumber2);
            
            CFArrayRef array = CFArrayCreate(NULL, (const void **)&windowID, 1, NULL);
            NSArray *windowInfos = (__bridge NSArray*)CGWindowListCreateDescriptionFromArray(array);
            CFRelease(array);
            
            NSString* windowTitle = [NSString new];
            if (windowInfos.count > 0) {
                NSDictionary *windowInfo = [windowInfos objectAtIndex:0];
                windowTitle = [NSString stringWithFormat:@"%@", [windowInfo objectForKey:(NSString *)kCGWindowName]];
            }
            
            [self updateEventStrings:[NSString stringWithFormat:@"MouseDown from:%@ windowTitle:%@",
                                      fromApi ? @"api" : @"mouse",
                                      windowTitle]];
            if (ignoreEvent == YES) {
                // 验证一下CGEventPostToPid发送鼠标事件是否有效
                
                // 原样转发有效
                //int pid = [pidField intValue];
                // CGEventPostToPid(pid, event);
                
                // 转发到其他进程无效
                // CGEventSetIntegerValueField(event, kCGEventTargetUnixProcessID, 878);
                // CGEventSetIntegerValueField(event, kCGMouseEventWindowUnderMousePointer, 145);
                // CGEventSetIntegerValueField(event, kCGMouseEventWindowUnderMousePointerThatCanHandleThisEvent, 145);
                // CGEventPostToPid(878, event);
                
                // 验证结论是鼠标事件只能发送给当前激活窗口
                
                return nil;
            }
        }
            break;
        case kCGEventLeftMouseUp:
        {
            NSLog(@"kCGEventLeftMouseUp*******************");
            
            Boolean ignoreEvent = YES;
            
            int64_t windowNumber = CGEventGetIntegerValueField(event, kCGMouseEventWindowUnderMousePointer);
            // 在同一个进程也可以根据目标窗口number精确过滤
            if (5032 == windowNumber) {
                ignoreEvent = NO;
            }
            
            if (ignoreEvent == YES) {
                // 验证一下CGEventPostToPid发送鼠标事件是否有效
                
                // 原样转发有效
                //int pid = [pidField intValue];
                // CGEventPostToPid(pid, event);
                
                // 转发到其他进程无效
                // CGEventSetIntegerValueField(event, kCGEventTargetUnixProcessID, 878);
                // CGEventSetIntegerValueField(event, kCGMouseEventWindowUnderMousePointer, 145);
                // CGEventSetIntegerValueField(event, kCGMouseEventWindowUnderMousePointerThatCanHandleThisEvent, 145);
                // CGEventPostToPid(878, event);
                
                // 验证结论是鼠标事件只能发送给当前激活窗口
                return nil;
            }
        }
            break;
        default:
            break;
    }
    return event;
}

- (void)updateEventStrings:(NSString*)string {
    NSLog(@"%@", string);
    self.text.stringValue = string;
}
@end
