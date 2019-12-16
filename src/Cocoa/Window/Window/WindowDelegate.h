//
//  WindowDelegate.h
//  Window
//
//  Created by barry on 2019/11/5.
//  Copyright © 2019 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 该类在由xib创建，相关IBAction事件在xib中手动关联到相关按钮
@interface WindowDelegate : NSObject

// 响应按钮点击动作
- (IBAction)showWindowBtnClick:(id)sender;
- (IBAction)closeWindowBtnClick:(id)sender;
- (IBAction)testControllerBtnClick:(id)sender;

-(void)threadFun;
-(void)createCodeWindowWapper;
-(void)createCodeWindow;

@end

NS_ASSUME_NONNULL_END
