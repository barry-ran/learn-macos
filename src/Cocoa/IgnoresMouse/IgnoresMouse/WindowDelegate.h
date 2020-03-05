//
//  WindowDelegate.h
//  IgnoresMouse
//
//  Created by barry on 2020/3/5.
//  Copyright © 2020 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowDelegate : NSObject <NSWindowDelegate>

// 响应按钮点击动作
- (IBAction)ignoresBtnClick:(id)sender;
- (IBAction)unIgnoresBtnClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
