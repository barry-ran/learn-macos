//
//  WindowDelegate.h
//  NSAccessibilityTester
//
//  Created by barry on 2019/12/18.
//  Copyright © 2019 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowDelegate : NSObject

- (void)openAccessibility;
- (NSArray*)allWindows;
- (void)printWindowInfo:(AXUIElementRef) window;

- (IBAction)moveWindowBtnClick:(id)sender;
- (void)printAllWindows;
- (void)printAllWindows2;
- (id) getWindow:(AXUIElementRef)window property :(NSString*)propType withDefaultValue:(id)defaultValue;

@end

NS_ASSUME_NONNULL_END
