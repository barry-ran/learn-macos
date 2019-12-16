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
    // 自定义私有成员变量,代码方式创建窗口
    NSWindow* codeWindow_;
    // 关联xib中相应的窗口
    IBOutlet NSWindow *xibWindow_;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"WindowDelegate init");
#if 1
        // 主线程中代码创建window
        [self createCodeWindow];
#else
        // 子线程中代码创建window
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
    [self createCodeWindowWapper];
}

-(void)createCodeWindowWapper
{
#if 1
    // 子线程中代码创建window是不允许的，会crash
    [self createCodeWindow];
#else
    // 同步到主线程执行是可以的
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self createCodeWindow];
    });
#endif
    
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
    // initWithContentRect创建一个view作为默认的content view， 我们可以自己通过contentView属性来修改
    codeWindow_ = [[NSWindow alloc] initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:YES];
    [codeWindow_ center];
}

- (void)testControllerBtnClick:(nonnull id)sender {
    NSLog(@"**************************\n");
    
    // contentView
    // xib会创建默认content view
    NSLog(@"xib window contentView:%p", [xibWindow_ contentView]);
    //initWithContentRect会创建一个默认的content view
    NSLog(@"code window contentView:%p", [codeWindow_ contentView]);
    
    NSLog(@"**************************\n");
    
    // contentViewController
    // 默认都没有contentViewController
    /*
     The main content view controller for the window. This provides the contentView of the window. Assigning this value will remove the existing contentView and will make the contentViewController.view the main contentView for the window. The default value is nil. The contentViewController only controls the contentView, and not the title of the window. The window title can easily be bound to the contentViewController with the following: [window bind:NSTitleBinding toObject:contentViewController withKeyPath:@"title" options:nil]. Setting the contentViewController will cause the window to resize based on the current size of the contentViewController. Autolayout should be used to restrict the size of the window. The value of the contentViewController is encoded in the NIB. Directly assigning a contentView will clear out the contentViewController.
     */
    NSLog(@"xib window contentViewController:%p", [xibWindow_ contentViewController]);
    NSLog(@"code window contentViewController:%p", [codeWindow_ contentViewController]);
    
    NSLog(@"**************************\n");
    
    // windowController
    // 默认没有windowController
    NSLog(@"xib window windowController:%p", [xibWindow_ windowController]);
    NSLog(@"code window windowController:%p", [codeWindow_ windowController]);
}

@end
