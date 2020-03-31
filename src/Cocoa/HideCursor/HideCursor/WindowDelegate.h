//
//  WindowDelegate.h
//  HideCursor
//
//  Created by barry on 2020/3/31.
//  Copyright © 2020 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowDelegate : NSObject

// 响应按钮点击动作
- (IBAction)NSCursorHide:(id)sender;
- (IBAction)HiddenUntilMouseMove:(id)sender;
- (IBAction)DisplayHideCursor:(id)sender;

@end

NS_ASSUME_NONNULL_END
