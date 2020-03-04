//
//  WindowDelegate.h
//  CatchMouseEvent
//
//  Created by barry on 2020/3/1.
//  Copyright © 2020 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 该类对象在xib中创建，相关IBAction事件在xib中手动关联到相关按钮
@interface WindowDelegate : NSObject {
    IBOutlet id pidField;
}

// 响应按钮点击动作
- (IBAction)catchBtnClick:(id)sender;
- (IBAction)unCatchBtnClick:(id)sender;

// 事件回调处理
- (CGEventRef)callback:(CGEventTapProxy)proxy
 type:(CGEventType)type
event:(CGEventRef)event;

@end

NS_ASSUME_NONNULL_END
