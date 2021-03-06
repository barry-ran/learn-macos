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
    Boolean catching_;
}

- (void)awakeFromNib {
    catching_ = NO;
    // 事件传播是沿着硬件系统 → window server → 用户session → 应用程序这条路径的，每个箭头处都可以捕捉事件，而这个参数就决定了在哪捕捉事件
    //              kCGHIDEventTap kCGSessionEventTap kCGAnnotatedSessionEventTap
    // 只有在kCGAnnotatedSessionEventTap阶段截获才能拿到kCGMouseEventWindowUnderMousePointer
    CGEventTapLocation location = kCGAnnotatedSessionEventTap;
    // 要捕获的事件
    CGEventMask mask = CGEventMaskBit(kCGEventLeftMouseDown) | CGEventMaskBit(kCGEventLeftMouseUp) | CGEventMaskBit(kCGEventMouseMoved) | CGEventMaskBit(kCGEventFlagsChanged);
    
    eventTap_ = CGEventTapCreate(location,                      // 捕获点
                                 kCGHeadInsertEventTap,         // 插入位置
                                 kCGEventTapOptionDefault,      // 捕获方式
                                 mask,                          // 捕获事件
                                 callback,                      // 回调函数
                                 (__bridge void*)(self));       // 自定义数据
    if (!eventTap_) {
        NSLog(@"eventTap_ is null");
        return;
    }
    source_ = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap_, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source_, kCFRunLoopCommonModes);
    
    // 默认是启用监听的，这里先关闭，由ui控制开关
    CGEventTapEnable(eventTap_, false);
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
    
    if (eventTap_ == NULL) {
        NSLog(@"eventTap_ == NULL");
        return;
    }
    CGEventTapEnable(eventTap_, true);
    catching_ = YES;
}

- (IBAction)unCatchBtnClick:(id)sender
{
    NSLog(@"unCatchBtnClick");
    if (eventTap_ == NULL) {
        NSLog(@"eventTap_ == NULL");
        return;
    }
    CGEventTapEnable(eventTap_, false);
    catching_ = NO;
}

- (CGEventRef)callback:(CGEventTapProxy)proxy
                  type:(CGEventType)type
                 event:(CGEventRef)event {
    switch (type) {
        case kCGEventTapDisabledByTimeout:
            // 如果回调的处理时间过长，监听会被置为失效，并收到这个事件
            NSLog(@"kCGEventTapDisabledByTimeout");
            if (catching_) {
                CGEventTapEnable(eventTap_, true);
            }
            break;
        case kCGEventLeftMouseDown:
        {
            NSLog(@"kCGEventLeftMouseDown*******************");
            
            // 区分事件源
            Boolean fromApi = NO;
#if 1
            // 可以直接获取事件的SourceStateID
            // 使用kCGEventSourceStatePrivate获取到的值是一个随机数，并不是-1，
            // 所以应该判断是否是kCGEventSourceStateHIDSystemState和kCGEventSourceStateCombinedSessionState
            int64_t sourceStateID = CGEventGetIntegerValueField(event, kCGEventSourceStateID);
            NSLog(@"sourceStateID: %lld", sourceStateID);
            if ((kCGEventSourceStateHIDSystemState != sourceStateID)
                && (kCGEventSourceStateCombinedSessionState != sourceStateID)) {
                fromApi = YES;
            }
#else
            // 之前不知道可以直接获取事件的SourceStateID，所以用了一个曲折的方法
            // 如果event的事件源是kCGEventSourceStatePrivate，则返回null
            CGEventSourceRef source = CGEventCreateSourceFromEvent(event);
            if(source) {
                CFRelease(source);
            } else {
                // 事件源是kCGEventSourceStatePrivate，所以是api生成的事件
                fromApi = YES;
            }
#endif
            // 获取进程信息
            // 确实可以过滤掉制定进程的事件，如果过滤鼠标左键按下的话，记得同时过滤左键抬起，否则会导致无法切换焦点窗口)
            int64_t processIdTarget = CGEventGetIntegerValueField(event, kCGEventTargetUnixProcessID);
            NSLog(@"processIdTarget: %lld", processIdTarget);
#if 0
            // 根据进程id过滤
            if (878 == processIdTarget) {
                return nil;
            }
#else
            // 根据进程名字过滤
            char ProcName[1024];
            proc_name((pid_t)CGEventGetIntegerValueField(event, kCGEventTargetUnixProcessID), ProcName, sizeof(ProcName));
            NSString *Target = [NSString stringWithUTF8String: ProcName];
            
            if ([Target isEqualToString: @"Finder"]) {
                return nil;
            }
#endif
            // 获取鼠标下窗口标题(mac中有两个坐标系，如果用CGEventGetLocation获取的坐标不能用来windowNumberAtPoint)
            CGPoint location = CGEventGetUnflippedLocation(event);
            NSLog(@"location: (%f,%f)", location.x, location.y);
            
            // 只有在kCGAnnotatedSessionEventTap阶段截获才能拿到kCGMouseEventWindowUnderMousePointer和kCGMouseEventWindowUnderMousePointerThatCanHandleThisEvent
            int64_t wn1 = CGEventGetIntegerValueField(event, kCGMouseEventWindowUnderMousePointer);
            int64_t wn2 = CGEventGetIntegerValueField(event, kCGMouseEventWindowUnderMousePointerThatCanHandleThisEvent);
            
            // windowNumberAtPoint的方式都可以拿到windowNumber
            NSInteger windowNumber = [NSWindow windowNumberAtPoint:location belowWindowWithWindowNumber:0];
            CGWindowID windowID = (CGWindowID)windowNumber;
            
            NSLog(@"window id: %lld,%lld,%ld", wn1, wn2, (long)windowNumber);
            
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
        }
            break;
        case kCGEventLeftMouseUp:
        {
            NSLog(@"kCGEventLeftMouseUp*******************");
            
            // 确实可以过滤掉制定进程的事件，如果过滤鼠标左键按下的话，记得同时过滤左键抬起，否则会导致无法切换焦点窗口)
            int64_t processIdTarget = CGEventGetIntegerValueField(event, kCGEventTargetUnixProcessID);
            NSLog(@"processIdTarget: %lld", processIdTarget);
#if 0
            // 根据进程id过滤
            if (878 == processIdTarget) {
                return nil;
            }
#else
            // 根据进程名字过滤
            char ProcName[1024];
            proc_name((pid_t)CGEventGetIntegerValueField(event, kCGEventTargetUnixProcessID), ProcName, sizeof(ProcName));
            NSString *Target = [NSString stringWithUTF8String: ProcName];
            
            if ([Target isEqualToString: @"Finder"]) {
                return nil;
            }
#endif
            
            // 获取鼠标下窗口标题(mac中有两个坐标系，如果用CGEventGetLocation获取的坐标不能用来windowNumberAtPoint)
            CGPoint location = CGEventGetUnflippedLocation(event);
            NSLog(@"location: (%f,%f)", location.x, location.y);
            
            int64_t wn1 = CGEventGetIntegerValueField(event, kCGMouseEventWindowUnderMousePointer);
            int64_t wn2 = CGEventGetIntegerValueField(event, kCGMouseEventWindowUnderMousePointerThatCanHandleThisEvent);
            
            // windowNumberAtPoint的方式都可以拿到windowNumber
            NSInteger windowNumber = [NSWindow windowNumberAtPoint:location belowWindowWithWindowNumber:0];
            
            NSLog(@"window id: %lld,%lld,%ld", wn1, wn2, (long)windowNumber);
        }
            break;
        case kCGEventMouseMoved:
        {
            // 获取鼠标下窗口标题(mac中有两个坐标系，如果用CGEventGetLocation获取的坐标不能用来windowNumberAtPoint)
            CGPoint location = CGEventGetUnflippedLocation(event);
            NSLog(@"location: (%f,%f)", location.x, location.y);
            
            // windowNumberAtPoint的方式都可以拿到windowNumber
            NSInteger windowNumber = [NSWindow windowNumberAtPoint:location belowWindowWithWindowNumber:0];
            
            NSLog(@"window id: %ld", (long)windowNumber);
            
            CFArrayRef array = CFArrayCreate(NULL, (const void **)&windowNumber, 1, NULL);
            NSArray *windowInfos = (__bridge NSArray*)CGWindowListCreateDescriptionFromArray(array);
            CFRelease(array);
            
            NSString* windowTitle = [NSString new];
            if (windowInfos.count > 0) {
                NSDictionary *windowInfo = [windowInfos objectAtIndex:0];
                windowTitle = [NSString stringWithFormat:@"%@", [windowInfo objectForKey:(NSString *)kCGWindowName]];
            }
            
            [self updateEventStrings:[NSString stringWithFormat:@"windowNumberAtPoint %ld, title:%@", windowNumber, windowTitle]];
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
