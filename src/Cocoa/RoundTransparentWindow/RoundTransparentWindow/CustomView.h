//
//  CustomView.h
//  RoundTransparentWindow
//
//  Created by barry on 2021/8/19.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomView : NSView {
    
    NSImage *circleImage;
    NSImage *pentagonImage;
    BOOL showingPentagon;
}

@property (retain) NSImage *circleImage;
@property (retain) NSImage *pentagonImage;
@property (assign) BOOL showingPentagon;

@end

NS_ASSUME_NONNULL_END
