//
//  AppDelegate.m
//  CustomTitlebar
//
//  Created by 冉坤(Barry.R) on 2023/1/6.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
{
    MainWindowController* mainWindowController_;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // nib文件介绍 https://danleechina.github.io/macOS-and-iOS-nib-file-principle-and-best-practice/#Managing-the-Lifetimes-of-Objects-from-Nib-Files
    // 如果使用NSWindowController管理NSWindow的话，
    // 就手动把MainMenu中的窗口删除，创建NSWindowController的同时选择创建xib
    // 然后使用initWithWindowNibName创建NSWindowController
    // 因为MainMenu.xib中的窗口是NSApplication创建并管理的
    // 而通过NSWindowController initWithWindowNibName加载xib并创建的窗口
    // 完全由NSWindowController管理
    mainWindowController_ = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    [mainWindowController_ showWindow:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
  return YES;
}

@end
