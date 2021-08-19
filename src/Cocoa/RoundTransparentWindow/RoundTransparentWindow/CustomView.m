//
//  CustomView.m
//  RoundTransparentWindow
//
//  Created by barry on 2021/8/19.
//

#import "CustomView.h"

@implementation CustomView

@synthesize circleImage;
@synthesize pentagonImage;
@synthesize showingPentagon;

/*
 This routine is called at app launch time when this class is unpacked from the nib.
 */
- (void)awakeFromNib {
    
    // Load the images from the bundle's Resources directory
    self.circleImage = [NSImage imageNamed:@"circle"];
    self.pentagonImage = [NSImage imageNamed:@"pentagon"];
}

/*
 When it's time to draw, this routine is called. This view is inside the window, the window's
 opaqueness has been turned off, and the window's styleMask has been set to NSBorderlessWindowMask
 on creation, so this view draws the all the visible content. The first two lines below fill the view
 with "clear" color, so that any images drawn also define the custom shape of the window.
 Furthermore, if the window's alphaValue is less than 1.0, drawing will use transparency.
 */
- (void)drawRect:(NSRect)rect {
    
    // Clear the drawing rect.
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    
    // A boolean tracks the previous shape of the window. If the shape changes, it's necessary for the
    // window to recalculate its shape and shadow.
    BOOL shouldDisplayWindow = NO;
    // If the window transparency is > 0.7, draw the circle, otherwise, draw the pentagon.
    if ([[self window] alphaValue] > 0.7) {
        shouldDisplayWindow = (showingPentagon == YES);
        showingPentagon = NO;
        [circleImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
        NSLog(@"draw circleImage");
    } else {
        shouldDisplayWindow = (showingPentagon == NO);
        showingPentagon = YES;
        [pentagonImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
        NSLog(@"draw pentagonImage");
    }
    // Reset the window shape and shadow.
    if (shouldDisplayWindow) {
        //[[self window] display];
        //[[self window] setHasShadow:NO];
        //[[self window] setHasShadow:YES];
    }
}

@end
