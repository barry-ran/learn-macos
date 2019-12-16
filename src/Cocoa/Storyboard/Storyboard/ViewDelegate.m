//
//  ViewDelegate.m
//  Storyboard
//
//  Created by barry on 2019/12/16.
//  Copyright © 2019 barry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewDelegate.h"

@implementation ViewDelegate
{
    // 关联storyboard中相应的view
    IBOutlet NSView *storyboardView_;
}

- (void)test:(nonnull id)sender {
    NSLog(@"**************************\n");
    
    // contentView
    // storyboard会创建默认contentView
    NSLog(@"storyboard window contentView:%p", [[storyboardView_ window] contentView]);
    
    
    NSLog(@"**************************\n");
    
    // contentViewController
    // storyboard会创建默认contentViewController
    NSLog(@"storyboard window contentViewController:%p", [[storyboardView_ window] contentViewController]);
    
    NSLog(@"**************************\n");
    
    // windowController
    // storyboard会创建默认windowController
    NSLog(@"storyboard window windowController:%p", [[storyboardView_ window] windowController]);
}

@end
