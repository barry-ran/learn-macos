//
//  AppDelegate.m
//  ShowAboveFullScreenWindow
//
//  Created by 冉坤(Barry.R) on 2024/8/7.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
NSPanel* panel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(300, 300, 500, 500)
                                                     styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable
                                                       backing:NSBackingStoreBuffered
                                                         defer:YES];
    // 显示在全屏窗口上面的必要条件：
    // 1. 必须NSPanel
    // 2. NSWindowStyleMaskNonactivatingPanel 窗口不激活app
    [panel setStyleMask:panel.styleMask|NSWindowStyleMaskNonactivatingPanel];
    // 3. NSWindowCollectionBehaviorCanJoinAllSpaces 可以显示在其他屏幕空间
    // 4. NSWindowCollectionBehaviorFullScreenAuxiliary 可以显示在全屏窗口屏幕空间
    [panel setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    // z序高一点
    [panel setLevel:kCGStatusWindowLevel];
    // 失焦不关闭
    [panel setReleasedWhenClosed:YES];
    [panel setHidesOnDeactivate:NO];
    [panel center];
    [panel orderFront:nil];
    
    // 测试NSWindow
    [_window setStyleMask:panel.styleMask|NSWindowStyleMaskNonactivatingPanel];
    [_window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    [_window setLevel:kCGStatusWindowLevel];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
