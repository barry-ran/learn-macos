//
//  Converter.h
//  CurrencyConverter
//
//  Created by barry on 2019/11/4.
//  Copyright © 2019 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Converter : NSObject

- (float)convertAmount:(float)amt atRate:(float)rate;
@end

NS_ASSUME_NONNULL_END
