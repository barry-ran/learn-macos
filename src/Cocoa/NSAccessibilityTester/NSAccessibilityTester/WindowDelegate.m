//
//  WindowDelegate.m
//  NSAccessibilityTester
//
//  Created by barry on 2019/12/18.
//  Copyright © 2019 barry. All rights reserved.
//
#import <AppKit/AppKit.h>

#import "WindowDelegate.h"

// https://github.com/mjolnirapp/AppGrid/blob/master/AppGrid/SDWindow.m
// https://github.com/kasper/phoenix/blob/master/Phoenix/PHWindow.m

// XXX: Undocumented private attribute for full screen mode
static NSString * const NSAccessibilityFullScreenAttribute = @"AXFullScreen";

// https://stackoverflow.com/questions/6178860/getting-window-number-through-osx-accessibility-api/6365105
// XXX: Undocumented private API to get the CGWindowID for an AXUIElementRef
AXError _AXUIElementGetWindow(AXUIElementRef element, CGWindowID *identifier);

@implementation WindowDelegate

- (void)moveWindowBtnClick:(nonnull id)sender {
    [self openAccessibility];
    
    NSLog(@"\n*****************************************");
#if 1
    [self printAllWindows];
#else
    [self printAllWindows2];
#endif
}

- (NSArray*) allWindows {
    NSMutableArray* windows = [NSMutableArray array];
    // 遍历所有运行的app
    for (NSRunningApplication* runningApp in [[NSWorkspace sharedWorkspace] runningApplications]) {
        // if ([runningApp activationPolicy] == NSApplicationActivationPolicyRegular) {
        // 创建 ax app
        AXUIElementRef app = AXUIElementCreateApplication([runningApp processIdentifier]);
        
        CFArrayRef _windows;
        // 获取app所有窗口
        AXError result = AXUIElementCopyAttributeValues(app, kAXWindowsAttribute, 0, 100, &_windows);
        if (result == kAXErrorSuccess) {
            for (NSInteger i = 0; i < CFArrayGetCount(_windows); i++) {
                AXUIElementRef win = CFArrayGetValueAtIndex(_windows, i);
                [windows addObject:CFRetain(win)];
            }
            CFRelease(_windows);
        }
        CFRelease(app);
        // }
    }
    return windows;
}

- (void)printWindowInfo:(nonnull AXUIElementRef)window {
    // NSAccessibilityTitleAttribute 获取到的是属性值
    // kAXTitleUIElementAttribute 获取到的是显示title的AXUIElementRef元素
    // NSLog(@"############# NSAccessibilityTitleAttribute %@", NSAccessibilityTitleAttribute); // AXTitle
    // NSLog(@"############# AXTitleUIElement %@", kAXTitleUIElementAttribute); // AXTitleUIElement
    // kAXRoleAttribute -- AXRole
    // NSAccessibilityRoleAttribute -- AXRole
    // CFTypeRef role2;
    // AXUIElementCopyAttributeValue(window, kAXRoleAttribute, (CFTypeRef *)&role2);
    
    // pid
    pid_t pid = -1;
    AXError result = AXUIElementGetPid(window, &pid);
    if (result == kAXErrorSuccess) {
        // NSLog(@"AXUIElementGetPid failed");
    }
    
    // title
    NSString* title = [self getWindow:window property:NSAccessibilityTitleAttribute withDefaultValue:@"null"];
    
    // role:
    NSString* role = [self getWindow:window property:NSAccessibilityRoleAttribute withDefaultValue:@"null"];
    
    // subRole
    NSString* subRole = [self getWindow:window property:NSAccessibilitySubroleAttribute withDefaultValue:@"null"];
    
    // getWindowProperty:
    Boolean minimized = [[self getWindow:window property:NSAccessibilityMinimizedAttribute withDefaultValue:@(NO)] boolValue];
    
    CGWindowID identifier;
    _AXUIElementGetWindow(window, &identifier);
    
    // fullScreen
    Boolean fullScreen = [[self getWindow:window property:NSAccessibilityFullScreenAttribute withDefaultValue:@(NO)] boolValue];

    
    NSLog(@"pid:%d, role:%@, subRole:%@, identifier:%d, title:%@, minimized:%d, fullScreen:%d", pid, role, subRole, identifier, title, minimized, fullScreen);
    
    /*
    CFTypeRef position;
    CGPoint point;
    
    // 获取窗口位置
    AXUIElementCopyAttributeValue(windowRef, kAXPositionAttribute, (CFTypeRef *)&position);
    AXValueGetValue(position, kAXValueCGPointType, &point);
    NSLog(@"point=%f,%f", point.x,point.y);
    
    // 创建一个位置
    CGPoint newPoint;
    newPoint.x = 0;
    newPoint.y = 0;
    NSLog(@"Create");
    position = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&newPoint));
    // 设置窗口位置
    NSLog(@"SetAttribute");
    AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute, position);
    */
}

- (void)openAccessibility { 
    // Boolean accessibilityTrust = AXIsProcessTrusted();
    // 获取访问权限（app在沙盒中不会弹出申请权限弹窗，需要在Signing & Capabilities中找到sandbox，点击sandbox最右侧的x号将其删除）
    Boolean accessibilityTrust = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)@{(__bridge id)kAXTrustedCheckOptionPrompt: @YES});
    NSLog(@"accessibilityTrust: %d", accessibilityTrust);
}

- (void)printAllWindows {
    NSArray* allWindows = [self allWindows];
    for (id windowRef in allWindows) {
        [self printWindowInfo:(AXUIElementRef)windowRef];
        CFRelease((AXUIElementRef)windowRef);
    }
}

- (void)printAllWindows2 { 
    @autoreleasepool {
        // 获取所有窗口（排除桌面元素）
        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly |
                                                           kCGWindowListExcludeDesktopElements, kCGNullWindowID);
        // 非Objective-C指针（CFArrayRef）移至Objective-C（NSArray* ），并将所有权转移到ARC
        NSArray* arr = CFBridgingRelease(windowList);
        // 遍历窗口数组
        for (NSMutableDictionary* entry in arr) {
            if (nil == entry) {
                NSLog(@"entry is nil");
                continue;
            }
            
            // 获取窗口进程id
            pid_t pid = [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
            // 使用pid创建app AXUIElement
            AXUIElementRef appRef = AXUIElementCreateApplication(pid);
            
            // 从app获取window列表
            CFArrayRef windowList;
            AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute, (CFTypeRef *)&windowList);
            
            CFRelease(appRef);
            
            if (windowList == nil) {
                //NSLog(@"windowList is null");
                continue;
            }
            
            CFIndex windowCount = CFArrayGetCount(windowList);
            if (windowCount < 1) {
                CFRelease(windowList);
                continue;
            }

            for (int i = 0; i < windowCount; i++) {
                AXUIElementRef itemRef = (AXUIElementRef) CFArrayGetValueAtIndex(windowList, i);
                [self printWindowInfo:itemRef];
                
            }
            
            CFRelease(windowList);
        }
    }
}

- (id) getWindow:(AXUIElementRef)window property :(NSString*)propType withDefaultValue:(id)defaultValue {
    CFTypeRef someProperty;
    if (AXUIElementCopyAttributeValue(window, (__bridge CFStringRef)propType, &someProperty) == kAXErrorSuccess)
        return CFBridgingRelease(someProperty);
    
    return defaultValue;
}

@end
