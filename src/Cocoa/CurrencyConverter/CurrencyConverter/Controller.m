//
//  Controller.m
//  CurrencyConverter
//
//  Created by barry on 2019/11/4.
//  Copyright © 2019 barry. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "Controller.h"
#import "Converter.h"

@implementation Controller

- (IBAction)convert:(id)sender
{
    // 读取ui控件的值
    float rate = [rateField floatValue];
    float amt = [dollarField floatValue];
    // 计算
    float total = [converter convertAmount:amt atRate:rate];
    // 设置ui控件的值
    // setFloatValue需要饱含appkit头文件
    [totalField setFloatValue:total];
}
@end
