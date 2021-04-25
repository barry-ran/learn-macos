//
//  AppDelegate.m
//  CheckWindowOcclusion
//
//  Created by barry on 2021/4/25.
//  Copyright © 2021 barry. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //创建Timer
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    //使用NSRunLoopCommonModes模式，把timer加入到当前Run Loop中。
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)timerCallback
{
    static int count = 0;
    count++;
    
    // https://developer.apple.com/documentation/appkit/nswindow/1419321-occlusionstate?language=objc
    // https://developer.apple.com/documentation/appkit/nswindowdidchangeocclusionstatenotification
    bool visible = self.window.occlusionState & NSWindowOcclusionStateVisible;
    NSLog(@"Timer %d: window visible state:%d", count, visible);
}

@end
