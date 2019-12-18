//
//  WindowDelegate.m
//  NSAccessibilityTester
//
//  Created by barry on 2019/12/18.
//  Copyright © 2019 barry. All rights reserved.
//

#import "WindowDelegate.h"

@implementation WindowDelegate

- (void)moveWindowBtnClick:(nonnull id)sender {
    @autoreleasepool {
    // 获取所有窗口
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
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
        NSLog(@"Ref = %@",appRef);

        // 从app获取window列表
        CFArrayRef windowList;
        AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute, (CFTypeRef *)&windowList);
        NSLog(@"WindowList = %@", windowList);
        if ((!windowList) || CFArrayGetCount(windowList)<1)
            continue;

        // 获取app中第一个window
        AXUIElementRef windowRef = (AXUIElementRef) CFArrayGetValueAtIndex( windowList, 0);
        CFTypeRef role;
        AXUIElementCopyAttributeValue(windowRef, kAXRoleAttribute, (CFTypeRef *)&role);
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
        sleep(5);
    }
    }
}

@end
