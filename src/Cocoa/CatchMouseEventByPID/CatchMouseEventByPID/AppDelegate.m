//
//  AppDelegate.m
//  CatchMouseEvent
//
//  Created by barry on 2020/3/1.
//  Copyright © 2020 barry. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property NSTimer* timer;
@end

@implementation AppDelegate

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    // 申请辅助权限（需要删除沙箱模式才会弹出权限申请窗口）
    // 删除沙箱： https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxQuickStart/AppSandboxQuickStart.html
    
    NSDictionary* options = @{(__bridge NSString*)(kAXTrustedCheckOptionPrompt) : @YES};
    if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                 repeats:YES
                                                   block:^(NSTimer* timer) {
                                                     [self relaunchIfProcessTrusted];
                                                   }];
    } else {
        NSLog(@"AXIsProcessTrustedWithOptions true");
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication {
  return YES;
}

- (void)relaunchIfProcessTrusted {
  if (AXIsProcessTrusted()) {
    [NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] executablePath] arguments:@[]];
    [NSApp terminate:nil];
  }
}


@end
