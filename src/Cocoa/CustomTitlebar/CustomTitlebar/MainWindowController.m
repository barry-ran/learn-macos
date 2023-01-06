#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    //将系统的标题栏设置透明
    self.window.titlebarAppearsTransparent = YES;
    //将系统标题进行隐藏
    self.window.titleVisibility = NSWindowTitleHidden;
    //设置window的内容部分充满整个窗口
    [self.window setStyleMask:[self.window styleMask] | NSWindowStyleMaskFullSizeContentView];
    
    // mac系统窗口的标题栏有三种过高度：
    // 小高度（终端窗口），中高度（xcode），大高度（访达）
    // 默认标题栏是是小高度
    // 增加Toolbar后（本例在xib中添加了一个空的ToolBar），可以通过设置setToolbarStyle调整标题栏另外两种高度：
    // NSWindowToolbarStyleUnified 大高度
    // NSWindowToolbarStyleUnifiedCompact 中高度
    [self.window setToolbarStyle:NSWindowToolbarStyleUnified];
}

- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
    // 设置窗口全屏时自动隐藏toolbar
    return (NSApplicationPresentationFullScreen |
        NSApplicationPresentationAutoHideMenuBar |
        NSApplicationPresentationAutoHideToolbar);
}

// 模拟appstore动态调整交通灯高度的效果：
// 1. 窗口非全屏标题栏为大高度（显示工具栏）
// 2. 窗口非全屏标题栏为小高度（隐藏工具栏）
- (void)windowDidEnterFullScreen:(NSNotification *)notification {
    [[self.window toolbar] setVisible:NO];
    NSLog(@"windowDidEnterFullScreen");
}

- (void)windowWillExitFullScreen:(NSNotification *)notification {
    // 在这里时机够早，但是交通灯没有重新布局
    [[self.window toolbar] setVisible:YES];
    // NSLog(@"windowWillExitFullScreen");
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
    // 在这里时太晚了，交通灯布局过程被看到了
    [[self.window toolbar] setVisible:YES];
    // NSLog(@"windowDidExitFullScreen");
}

- (void)windowDidResize:(NSNotification *)notification {
    // 这里时机合适，但是不要执行太频繁
    if (![[self.window toolbar] isVisible]) {
        [[self.window toolbar] setVisible:YES];
    }
    NSLog(@"windowDidResize");
}

@end
