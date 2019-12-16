//
//  ViewDelegate.h
//  Storyboard
//
//  Created by barry on 2019/12/16.
//  Copyright © 2019 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewDelegate : NSObject

// 返回值为IBAction的方法会被IB识别为可连接，可以连接到按钮的点击动作
- (IBAction)test:(id)sender;

@end

NS_ASSUME_NONNULL_END
