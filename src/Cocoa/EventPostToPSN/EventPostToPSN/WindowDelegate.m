//
//  WindowDelegate.m
//  EventPostToPSN
//
//  Created by barry on 2020/3/2.
//  Copyright © 2020 barry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WindowDelegate.h"

@implementation WindowDelegate

- (IBAction)postBtnClick:(id)sender
{
    NSLog(@"postBtnClick");
    
    // cmd+w 关闭窗口
    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    
    // 这里有按键码 https://www.sunyazhou.com/2017/02/22/macOS-simulate-keyborad-NSEvent/
    CGEventRef wDown = CGEventCreateKeyboardEvent(src, 0x0D, true);
    CGEventRef wUp = CGEventCreateKeyboardEvent(src, 0x0D, false);

    // cmd
    CGEventSetFlags(wDown, kCGEventFlagMaskCommand);
    CGEventSetFlags(wUp, kCGEventFlagMaskCommand);

#if 0
    // 发送事件到全局（在按钮点击里触发这段代码的话，最终cmd+w事件会被当前窗口处理，也就是当前窗口会关闭）
    CGEventTapLocation loc = kCGHIDEventTap; // kCGSessionEventTap also works
    CGEventPost(loc, wDown);
    CGEventPost(loc, wUp);
#else
    // 发送事件到指定进程
    /*
     1. CGEventPostToPSN的参数之一ProcessSerialNumber相关的任何api都已经标记为过时，所以目前拿不到ProcessSerialNumber
     2. CGEventPostToPid可以替代CGEventPostToPSN，可以发送键盘事件到任意进程，但是鼠标事件不行，mac系统会阻止，详见下面链接
     3. 实际验证，鼠标事件只能发送给当前激活窗口，其他窗口无效
     4. 键盘事件转发没问题
     **/
    //
    // https://stackoverflow.com/questions/42657655/how-to-send-mouse-click-event-to-a-window-in-mac-osx
    
    
    // 这里点击左上角的苹果图标（因为当前窗口是激活窗口，所以可以点击到自己的menu）
    // pid_t pid = getpid ();
    // NSWindow *window = [[NSApplication sharedApplication] mainWindow];
    // long windowNum = [window windowNumber];
    // CGPoint point = {34, 15};
    
    // 鼠标事件转发到其他窗口无效(通过截获进程鼠标事件，发现实际发送到目标进程了，但是也不会响应，苹果做了保护)
    pid_t pid = 483;
    int windowNum = 110;
    // 注意y坐标系相反
    CGPoint point = {63, 1050 - 948};
    
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStatePrivate);
    CGMouseButton button = kCGMouseButtonLeft;
    
    // down
    CGEventType type = kCGEventLeftMouseDown;
    int64_t clickCount = 1;
    CGEventRef mouseDown = CGEventCreateMouseEvent(source, type, point, button);
    CGEventSetIntegerValueField(mouseDown, kCGMouseEventClickState, clickCount);
    CGEventSetIntegerValueField(mouseDown, kCGMouseEventWindowUnderMousePointer, windowNum);
    CGEventSetIntegerValueField(mouseDown, kCGMouseEventWindowUnderMousePointerThatCanHandleThisEvent, windowNum);
    CGEventSetType(mouseDown, type);
    
    // up
    type = kCGEventLeftMouseUp;
    clickCount = 2;
    CGEventRef mouseUp = CGEventCreateMouseEvent(source, type, point, button);
    CGEventSetIntegerValueField(mouseUp, kCGMouseEventClickState, clickCount);
    CGEventSetIntegerValueField(mouseUp, kCGMouseEventWindowUnderMousePointer, windowNum);
    CGEventSetIntegerValueField(mouseUp, kCGMouseEventWindowUnderMousePointerThatCanHandleThisEvent, windowNum);
    CGEventSetType(mouseUp, type);
    
    CGEventPostToPid(pid, mouseDown);
    CGEventPostToPid(pid, mouseUp);
    
    CFRelease(mouseDown);
    CFRelease(mouseUp);
    CFRelease(source);
    
    // 转发键盘事件没问题
    //CGEventPostToPid(pid, wDown);
    //CGEventPostToPid(pid, wUp);
#endif

    CFRelease(wDown);
    CFRelease(wUp);
    CFRelease(src);
}

@end
