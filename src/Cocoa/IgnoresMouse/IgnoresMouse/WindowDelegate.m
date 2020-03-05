//
//  WindowDelegate.m
//  IgnoresMouse
//
//  Created by barry on 2020/3/5.
//  Copyright © 2020 barry. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "WindowDelegate.h"

@implementation WindowDelegate
{
    // 关联xib中相应的窗口
    IBOutlet NSWindow *testWindow_;
    IBOutlet NSWindow *mainWindow_;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // 注册NSWindowDelegate
    mainWindow_.delegate = self;
}

- (void)windowWillClose:(NSNotification *)notification {
    // 注册NSWindowDelegate后才可以收到这里的通知
    [testWindow_ close];
}

- (void)unIgnoresBtnClick:(nonnull id)sender {
    NSLog(@"unIgnoresBtnClick");
    // 恢复鼠标事件响应
    testWindow_.ignoresMouseEvents = false;
}

- (void)ignoresBtnClick:(nonnull id)sender {
    NSLog(@"ignoresBtnClick");
    // 不响应鼠标事件，鼠标事件穿透到下面的窗口
    testWindow_.ignoresMouseEvents = true;
}

@end
