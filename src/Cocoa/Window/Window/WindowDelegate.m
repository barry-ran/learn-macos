//
//  WindowDelegate.m
//  Window
//
//  Created by barry on 2019/11/5.
//  Copyright © 2019 barry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowDelegate.h"

@implementation WindowDelegate
{
    NSWindow* codeWindow_;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"WindowDelegate init");
#if 1
        [self createCodeWindow];
#else
        NSThread *newThread = [[NSThread alloc]initWithTarget:self selector:@selector(threadFun) object:nil];
        [newThread start];
#endif
    }
    return self;
}

- (IBAction)showWindowBtnClick:(id)sender
{
    NSLog(@"showWindowBtnClick");
    [codeWindow_ makeKeyAndOrderFront:nil];
}

- (IBAction)closeWindowBtnClick:(id)sender
{
    NSLog(@"closeWindowBtnClick");
    [codeWindow_ orderOut:nil];
}

-(void)threadFun
{
    NSLog(@"thread fun");
    [self createCodeWindow];
}

-(void)createCodeWindow
{
    // 和windows不一样，ui相关操作只能在主线程调用
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = 400;
    frame.size.height = 300;
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
    // initWithContentRect只能在主线程调用
    codeWindow_ = [[NSWindow alloc] initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:YES];
    [codeWindow_ center];
}
@end
