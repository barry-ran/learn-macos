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

#if 1
    // 发送事件到全局（在按钮点击里触发这段代码的话，最终cmd+w事件会被当前窗口处理，也就是当前窗口会关闭）
    CGEventTapLocation loc = kCGHIDEventTap; // kCGSessionEventTap also works
    CGEventPost(loc, wDown);
    CGEventPost(loc, wUp);
#else
    // 发送事件到指定进程
    /*
     1. CGEventPostToPSN的参数之一ProcessSerialNumber相关的任何api都已经标记为过时，所以目前拿不到ProcessSerialNumber
     2. CGEventPostToPid可以替代CGEventPostToPSN，可以发送键盘事件到任意进程，但是鼠标事件不行，mac系统会阻止，详见下面链接
     **/
    //
    // https://stackoverflow.com/questions/42657655/how-to-send-mouse-click-event-to-a-window-in-mac-osx
    ProcessSerialNumber psn;
    CGEventPostToPSN(&psn, wDown);
    CGEventPostToPSN(&psn, wUp);
#endif

    CFRelease(wDown);
    CFRelease(wUp);
    CFRelease(src);
}

@end
