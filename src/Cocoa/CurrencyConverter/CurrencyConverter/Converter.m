//
//  Converter.m
//  CurrencyConverter
//
//  Created by barry on 2019/11/4.
//  Copyright © 2019 barry. All rights reserved.
//

#import "Converter.h"

@implementation Converter

- (float)convertAmount:(float)amt atRate:(float)rate { 
    return (amt * rate);
}

@end
