//
//  WindowDelegate.m
//  HideCursor
//
//  Created by barry on 2020/3/31.
//  Copyright © 2020 barry. All rights reserved.
//

#import "WindowDelegate.h"

#import <Cocoa/Cocoa.h>

@implementation WindowDelegate


- (void)DisplayHideCursor:(nonnull id)sender {
    NSLog(@"DisplayHideCursor");
    [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer)
    {
        NSLog(@"hide cursor");
        // 只能控制当前应用的指针显隐，也就是当应用有键盘焦点的时候才生效
        // 这个函数每次调用是将指针隐藏计数+1，CGDisplayShowCursor是将指针隐藏计数-1
        // 当指针隐藏计数等于0的时候鼠标指针是显示的
        // 指针隐藏计数是和应用绑定的，CGDisplayHideCursor/CGDisplayShowCursor只设置本应用的指针隐藏计数
        // 所以CGDisplayHideCursor和CGDisplayShowCursor需要成对调用，否则鼠标显示异常
        // https://developer.apple.com/documentation/coregraphics/1455867-cgdisplayshowcursor?language=objc
        CGDisplayHideCursor(kCGDirectMainDisplay);
        // 如果这里多调用一次CGDisplayHideCursor，最后鼠标指针的隐藏计数为1，鼠标指针是不显示的
        // CGDisplayHideCursor(kCGDirectMainDisplay);
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:10 repeats:NO block:^(NSTimer * _Nonnull timer)
    {
        NSLog(@"show cursor");
        CGDisplayShowCursor(kCGDirectMainDisplay);
        // CGDisplayShowCursor(kCGDirectMainDisplay);
    }];
}

- (void)HiddenUntilMouseMove:(nonnull id)sender { 
    NSLog(@"HiddenUntilMouseMove");
    [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer)
    {
        NSLog(@"setHiddenUntilMouseMoves YES");
        // 同样只能控制当前应用的指针显隐，也就是当应用有键盘焦点的时候才生效
        // https://developer.apple.com/documentation/appkit/nscursor/1534665-sethiddenuntilmousemoves?language=objc
        [NSCursor setHiddenUntilMouseMoves:YES];
    }];
}

- (void)NSCursorHide:(nonnull id)sender { 
    NSLog(@"NSCursorHide");
    [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer)
    {
        NSLog(@"NSCursor hide");
        // 同样只能控制当前应用的指针显隐，也就是当应用有键盘焦点的时候才生效
        // https://developer.apple.com/documentation/appkit/nscursor/1527345-hide?language=objc
        [NSCursor hide];
        // 和CGDisplayHideCursor表现一致，也有隐藏计数的概念，hide和unhide需要成对调用
        [NSCursor hide];
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:10 repeats:NO block:^(NSTimer * _Nonnull timer)
    {
        NSLog(@"NSCursor unhide");
        // 同样只能控制当前应用的指针显隐，也就是当应用有键盘焦点的时候才生效
        // https://developer.apple.com/documentation/appkit/nscursor/1532996-unhide?language=objc
        [NSCursor unhide];
        [NSCursor unhide];
    }];
}

@end
