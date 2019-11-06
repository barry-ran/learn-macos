//
//  WindowDelegate.h
//  Window
//
//  Created by barry on 2019/11/5.
//  Copyright © 2019 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowDelegate : NSObject

- (IBAction)showWindowBtnClick:(id)sender;
- (IBAction)closeWindowBtnClick:(id)sender;

-(void)threadFun;
-(void)createCodeWindowWapper;
-(void)createCodeWindow;

@end

NS_ASSUME_NONNULL_END
