//
//  CustomWindow.m
//  RoundTransparentWindow
//
//  Created by barry on 2021/8/19.
//

#import "CustomWindow.h"

#import <AppKit/AppKit.h>

@implementation CustomWindow

@synthesize initialLocation;

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSWindowStyleMask)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag {
    
    // Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        // Start with no transparency for all drawing into the window
        [self setAlphaValue:1.0];
        // Turn off opacity so that the parts of the window that are not drawn into are transparent.
        // 网上教程都要加这一行，测试了这行加不加好像没有区别，暂时没有发现它的作用
        [self setOpaque:NO];
        
        // 这个才会实现不规则窗口
        [self setBackgroundColor: [NSColor clearColor]];
    }
    return self;
}

/*
 This method changes the transparency for the entire window. Thus, all objects drawn in this window,
 even if drawn at full alpha value, will pick up this setting.
 */
- (IBAction)changeTransparency:(id)sender {
    NSLog(@"changeTransparency: %f", [sender floatValue]);
    // Set the window's alpha value. This will cause the views in the window to redraw.
    [self setAlphaValue:[sender floatValue]];
    [[self contentView] setNeedsDisplay:true];
    
}

/*
 Custom windows that use the NSBorderlessWindowMask can't become key by default. Override this method
 so that controls in this window will be enabled.
 */
- (BOOL)canBecomeKeyWindow {
    
    return YES;
}

/*
 Start tracking a potential drag operation here when the user first clicks the mouse, to establish
 the initial location.
 */
- (void)mouseDown:(NSEvent *)theEvent {
    
    // Get the mouse location in window coordinates.
    self.initialLocation = [theEvent locationInWindow];
}

/*
 Once the user starts dragging the mouse, move the window with it. The window has no title bar for
 the user to drag (so we have to implement dragging ourselves)
 */
- (void)mouseDragged:(NSEvent *)theEvent {
    
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    NSPoint newOrigin = windowFrame.origin;

    // Get the mouse location in window coordinates.
    NSPoint currentLocation = [theEvent locationInWindow];
    // Update the origin with the difference between the new mouse location and the old mouse location.
    newOrigin.x += (currentLocation.x - initialLocation.x);
    newOrigin.y += (currentLocation.y - initialLocation.y);

    // Don't let window get dragged up under the menu bar
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    
    // Move the window to the new location
    [self setFrameOrigin:newOrigin];
}

@end
