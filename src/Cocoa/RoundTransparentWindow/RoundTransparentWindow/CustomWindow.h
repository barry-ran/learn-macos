//
//  CustomWindow.h
//  RoundTransparentWindow
//
//  Created by barry on 2021/8/19.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomWindow : NSWindow {
    // this point is used in dragging to mark the initial click location
    NSPoint initialLocation;
}

@property (assign) NSPoint initialLocation;

- (IBAction)changeTransparency:(id)sender;

@end

NS_ASSUME_NONNULL_END
