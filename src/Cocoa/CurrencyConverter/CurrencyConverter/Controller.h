//
//  Controller.h
//  CurrencyConverter
//
//  Created by barry on 2019/11/4.
//  Copyright © 2019 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 实现该类后，需要将Controller作为IB Object添加到xib中，
// 添加到地方和添加label控件的地方一样，输入object选择名为Object的蓝色立方体拖进xib
// 然后选中刚添加的object，在右侧属性栏将Custom Class中的Class选择为Controller
// 就可以在连接属性栏发现IBOutlet变量和IBAction方法了，点击加号拖出一条线连接相应的ui控件即可
@interface Controller : NSObject {
    // IBOutlet变量用来绑定到IB控件，方便读写控件的值
    IBOutlet id converter;
    IBOutlet id dollarField;
    IBOutlet id rateField;
    IBOutlet id totalField;
}
// 返回值为IBAction的方法会被IB识别为可连接，可以连接到按钮的点击动作
- (IBAction)convert:(id)sender;
@end

NS_ASSUME_NONNULL_END
