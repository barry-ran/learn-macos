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
NSWindow *testWindow;
// 最终总结：
// 辅助进程（开了LSUIElement或者setActivationPolicy设置了NSApplicationActivationPolicyAccessory）不需要设置NSWindowStyleMaskNonactivatingPanel也可以让NSPanel和NSWindow显示在其他全屏窗口上面
// 普通进程只能让有NSWindowStyleMaskNonactivatingPanel的NSPanel显示在其他全屏窗口上面，NSWindow不支持设置NSWindowStyleMaskNonactivatingPanel
// LSUIElement在info.plist中静态设置辅助进程和普通进程
// setActivationPolicy可以运行后动态设置辅助进程和普通进程
// 只要NSPanel/NSWindow（不设置NSWindowStyleMaskNonactivatingPanel）创建时是辅助进程，即使之后改为普通进程，也还是可以显示在其他全屏窗口上面
// 为什么这么不喜欢NSWindowStyleMaskNonactivatingPanel？因为在macos12以上有轻击触摸板窗口没有焦点的bug（macos12及以下没有问题）
// NSWindowStyleMaskNonactivatingPanel的命名和官方文档说明就是它只对Pannel有影响，会产生两种影响：
// 1. 可以让NSPannel显示在其他全屏窗口上面（配合下面behavior等条件）（macos12及以下要早于behavior设置）
// 2. 在macos13及以上，触摸板轻击其他窗口，再轻击当前应用的NSWindowStyleMaskNonactivatingPanel的窗口，窗口无法获得焦点
// 没有焦点后再重击轻击都不行了，必须手动激活其他程序，再回来轻击当前应用的非NSWindowStyleMaskNonactivatingPanel窗口或者重击NSWindowStyleMaskNonactivatingPanel窗口
// 应该是mac的bug，macos12同样程序同样操作没有问题

// 在info.plist里面开启LSUIElement yes以后这里也同步放开测试效果
// #define LSUIElement
#ifdef LSUIElement
// 设置LSUIElement以后，会导致进程没有dock图标&窗口没有菜单栏&全屏红绿灯
// https://developer.apple.com/documentation/appkit/nsapplication/activationpolicy-swift.enum?language=objc
// 可以在进程启动时通过设置setActivationPolicy
// NSApplicationActivationPolicyRegular动态把进程改为普通进程，这样dock图标这些就回来了
// 但是普通进程创建非NSWindowStyleMaskNonactivatingPanel的NSPanel无法显示在其他全屏窗口上面了
// 但是只要在创建NSPanel之前临时把进程设置为NSApplicationActivationPolicyAccessory，创建完NSPanel再设置回NSApplicationActivationPolicyRegular
// 就可以保证依然是普通进程，但是NSPanel不需要NSWindowStyleMaskNonactivatingPanel也可以悬浮在其他全屏窗口上面
// 动态设置进程属性的缺点是dock图标会消失再出现，次数多了还会导致永远消失或者变得很小，只能执行killallDock命令重启dock
// #define LSUIElement_dock
#endif

// 设置了进程属性后NSWindowStyleMaskNonactivatingPanel有没有就无所谓了，有的话还会带来轻击触摸板窗口没有焦点的bug
//#define FIX_QT_MAC13BELOW_NSWindowStyleMaskNonactivatingPanel_NOT_WORK_BUG

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#ifdef LSUIElement_dock
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
#endif

  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
#ifdef FIX_QT_MAC13BELOW_NSWindowStyleMaskNonactivatingPanel_NOT_WORK_BUG
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
#endif
        panel = [[NSPanel alloc]
            initWithContentRect:NSMakeRect(300, 300, 500, 500)
                      styleMask:NSWindowStyleMaskTitled |
                                NSWindowStyleMaskClosable |
                                NSWindowStyleMaskMiniaturizable |
                                NSWindowStyleMaskResizable
                        backing:NSBackingStoreBuffered
                          defer:YES];
    // macos 13以下的额外要求（具体来说是12.4以下）：
    // 重要！！！：在macos 13以下，如果在设置NSWindowStyleMaskNonactivatingPanel style之前设置下面的behavior，会无效
    // 并且导致即使设置NSWindowStyleMaskNonactivatingPanel style之后再次设置behavior，依然会无效
    // 这也是为什么macos 13以下在qt中即使按下面条件设置了style和behavior也始终不能显示在全屏窗口上面的原因
    // 因为qt内部会早早设置behavior，导致后面我们应用层设置NSWindowStyleMaskNonactivatingPanel没效果，只能通过修改qt源码解决
    // [panel setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    // 参考自telegram
    // https://github.com/Etersoft/telegram-desktop/blob/3e4b3801e4d0c65bf06b73b48982d82fd6be318f/tdesktop/Telegram/Patches/qtbase_5_6_2.diff#L860
    // 解决qt bug还有一个方法：在macos13以下，创建窗口之前动态设置进程为辅助进程，创建完窗口再设置回普通进程FIX_QT_MAC13BELOW_NSWindowStyleMaskNonactivatingPanel_NOT_WORK_BUG
    
    // macos 13及以上没有这个问题，只要满足下面6个条件
    // 显示在其他app的全屏窗口上面的必要条件：
        // 3. NSWindowCollectionBehaviorCanJoinAllSpaces 可以显示在其他屏幕空间
        // 4. NSWindowCollectionBehaviorFullScreenAuxiliary 可以显示在全屏窗口屏幕空间
        [panel setCollectionBehavior:
                   NSWindowCollectionBehaviorCanJoinAllSpaces |
                   NSWindowCollectionBehaviorFullScreenAuxiliary];

#if defined(LSUIElement) && !defined(FIX_QT_MAC13BELOW_NSWindowStyleMaskNonactivatingPanel_NOT_WORK_BUG)
        // 1. 必须NSPanel
        // 2. NSWindowStyleMaskNonactivatingPanel 窗口不激活app
        [panel
            setStyleMask:panel.styleMask | NSWindowStyleMaskNonactivatingPanel];
#endif

        // 5. z序高一点
        [panel setLevel:kCGStatusWindowLevel];
        // 6. 失焦不关闭
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
        NSTextField *textField =
            [[NSTextField alloc] initWithFrame:NSMakeRect(20, 80, 260, 24)];
        [textField setPlaceholderString:@"输入些内容"];
        [panel.contentView addSubview:textField];

        // 创建关闭按钮
        NSButton *closeButton =
            [[NSButton alloc] initWithFrame:NSMakeRect(100, 30, 100, 30)];
        [closeButton setTitle:@"关闭"];
        [closeButton setTarget:self];
        [closeButton setAction:@selector(closePanel:)];
        [panel.contentView addSubview:closeButton];

        // 测试NSWindowStyleMaskNonactivatingPanel的bug：
        // mac开启触摸板轻击功能，在NSPannel没有获得焦点的时候，直接轻击测试失焦按钮，弹出的测试失焦窗口没有焦点，需要点击其他窗口再点回来才行
        // 核心点在于，焦点给到别的窗口以后，怎么轻击NSWindowStyleMaskNonactivatingPanel的窗口，都不会使该窗口获得焦点，从它这里弹出其他窗口也不会获得焦点
        // 更进一步测试：进程既有普通窗口也有NSWindowStyleMaskNonactivatingPanel窗口，当进程没有窗口的时候，如果第一次轻击了NSWindowStyleMaskNonactivatingPanel窗口
        // 再怎么轻击重击这个进程的其他窗口，都无法获得焦点，只有点一下其他进程的窗口获得焦点，再点一下当前进程的非NSWindowStyleMaskNonactivatingPanel窗口，才能让当前进程重新获得焦点
        // 重击没问题，因为重击会使NSPannel获得焦点
        // 创建测试失焦按钮
        NSButton *testFocusButton =
            [[NSButton alloc] initWithFrame:NSMakeRect(220, 30, 120, 30)];
        [testFocusButton setTitle:@"测试失焦按钮"];
        [testFocusButton setTarget:self];
        [testFocusButton setAction:@selector(testFocusButtonClicked:)];
        [panel.contentView addSubview:testFocusButton];

#ifdef FIX_QT_MAC13BELOW_NSWindowStyleMaskNonactivatingPanel_NOT_WORK_BUG
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
#endif
      });

  // 测试NSWindow(NSWindow不支持NSWindowStyleMaskNonactivatingPanel，所以不开LSUIElement的场景下NSWindow不能显示在其他app的全屏窗口上)
  // NSWindowStyleMaskNonactivatingPanel官方文档说明只支持NSPannel
  // https://developer.apple.com/documentation/appkit/nswindow/stylemask-swift.struct/nonactivatingpanel?language=objc
#ifndef LSUIElement
    [_window setStyleMask:_window.styleMask | NSWindowStyleMaskNonactivatingPanel];
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

    // 创建测试失焦窗口
    testWindow =
        [[NSWindow alloc] initWithContentRect:NSMakeRect(400, 400, 400, 300)
                                    styleMask:NSWindowStyleMaskTitled |
                                              NSWindowStyleMaskClosable |
                                              NSWindowStyleMaskMiniaturizable |
                                              NSWindowStyleMaskResizable
                                      backing:NSBackingStoreBuffered
                                        defer:YES];
    [testWindow setTitle:@"测试失焦窗口"];

    // 在测试窗口中间显示文字
    NSTextField *testWindowLabel =
        [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 40)];
    [testWindowLabel setStringValue:@"测试失焦窗口"];
    [testWindowLabel setBezeled:NO];
    [testWindowLabel setDrawsBackground:NO];
    [testWindowLabel setEditable:NO];
    [testWindowLabel setSelectable:NO];
    [testWindowLabel setAlignment:NSTextAlignmentCenter];
    [testWindowLabel setFont:[NSFont systemFontOfSize:20
                                               weight:NSFontWeightBold]];
    [testWindowLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [testWindow.contentView addSubview:testWindowLabel];
    [NSLayoutConstraint activateConstraints:@[
      [testWindowLabel.centerXAnchor
          constraintEqualToAnchor:testWindow.contentView.centerXAnchor],
      [testWindowLabel.centerYAnchor
          constraintEqualToAnchor:testWindow.contentView.centerYAnchor]
    ]];
    // 默认隐藏
    // [testWindow orderOut:nil]; // 不需要，因为创建时默认就是隐藏的
}

- (void)closePanel:(id)sender {
    [panel close]; // 关闭面板
}

- (void)testFocusButtonClicked:(id)sender {
  // 隐藏当前窗口（panel）
  [panel orderOut:nil];

  // 显示测试失焦窗口
  [testWindow center];
  [testWindow makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
