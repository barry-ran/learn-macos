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
// 开了LSUIElement以后就不需要NSWindowStyleMaskNonactivatingPanel了
// 在info.plist里面开启LSUIElement yes以后这里也同步放开测试效果
#define LSUIElement
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(300, 300, 500, 500)
                                           styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable
                                                       backing:NSBackingStoreBuffered
                                                         defer:YES];
        // 重要！！！：如果在设置NSWindowStyleMaskNonactivatingPanel style之前设置下面的behavior，会无效
        // 并且导致即使设置NSWindowStyleMaskNonactivatingPanel style之后再次设置behavior，依然会无效
        // 这也是为什么在qt中即使设置了NSWindowCollectionBehaviorFullScreenAuxiliary始终不能显示在全屏窗口上面的原因
        // [panel setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
        // 参考自telegram https://github.com/Etersoft/telegram-desktop/blob/3e4b3801e4d0c65bf06b73b48982d82fd6be318f/tdesktop/Telegram/Patches/qtbase_5_6_2.diff#L860
    
        // 显示在其他app的全屏窗口上面的必要条件：
#ifndef LSUIElement
        // 1. 必须NSPanel
        // 2. NSWindowStyleMaskNonactivatingPanel 窗口不激活app
        [panel setStyleMask:panel.styleMask|NSWindowStyleMaskNonactivatingPanel];
#endif
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

        // 在panel中间显示文字NSPanel
        NSTextField *panelLabel =
            [[NSTextField alloc] initWithFrame:NSMakeRect(150, 250, 200, 40)];
        [panelLabel setStringValue:@"NSPanel"];
        [panelLabel setBezeled:NO];
        [panelLabel setDrawsBackground:NO];
        [panelLabel setEditable:NO];
        [panelLabel setSelectable:NO];
        [panelLabel setAlignment:NSTextAlignmentCenter];
        [panelLabel setFont:[NSFont systemFontOfSize:24
                                              weight:NSFontWeightBold]];
        [panel.contentView addSubview:panelLabel];

        // 创建文本输入框
        NSTextField* textField = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 80, 260, 24)];
        [textField setPlaceholderString:@"输入些内容"];
        [panel.contentView addSubview:textField];
            
            // 创建关闭按钮
        NSButton* closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(100, 30, 100, 30)];
        [closeButton setTitle:@"关闭"];
        [closeButton setTarget:self];
        [closeButton setAction:@selector(closePanel:)];
        [panel.contentView addSubview:closeButton];
    });
    
    // 测试NSWindow (NSWindow不支持NSWindowStyleMaskNonactivatingPanel，所以不开LSUIElement的场景下NSWindow不能显示在其他app的全屏窗口上)
#ifndef LSUIElement
    [_window setStyleMask:panel.styleMask|NSWindowStyleMaskNonactivatingPanel];
#endif
    [_window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    [_window setLevel:kCGStatusWindowLevel];

    // 在_window中间显示文字NSWindow
    NSTextField *windowLabel =
        [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 40)];
    [windowLabel setStringValue:@"NSWindow"];
    [windowLabel setBezeled:NO];
    [windowLabel setDrawsBackground:NO];
    [windowLabel setEditable:NO];
    [windowLabel setSelectable:NO];
    [windowLabel setAlignment:NSTextAlignmentCenter];
    [windowLabel setFont:[NSFont systemFontOfSize:24 weight:NSFontWeightBold]];
    // 设置自动布局约束，让标签居中
    [windowLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_window.contentView addSubview:windowLabel];
    [NSLayoutConstraint activateConstraints:@[
      [windowLabel.centerXAnchor
          constraintEqualToAnchor:_window.contentView.centerXAnchor],
      [windowLabel.centerYAnchor
          constraintEqualToAnchor:_window.contentView.centerYAnchor]
    ]];
}

- (void)closePanel:(id)sender {
    [panel close]; // 关闭面板
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
