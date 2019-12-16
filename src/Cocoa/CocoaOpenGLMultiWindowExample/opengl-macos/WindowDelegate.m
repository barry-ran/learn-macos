//
//  WindowDelegate.m
//  opengl-macos
//
//  Created by Xavier Slattery on 13/2/18.
//  Copyright © 2018 Xavier Slattery. All rights reserved.
//

#import "WindowDelegate.h"
#import "AppDelegate.h"

@implementation WindowDelegate

- (void)awakeFromNib {
	[self makeKeyAndOrderFront:nil];
}

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)canBecomeKeyWindow { return YES; }
- (BOOL)canBecomeMainWindow { return YES; }

- (BOOL)isMovableByWindowBackground { return YES; }

- (void)becomeKeyWindow {
	[super becomeKeyWindow];
	
//	NSLog(@"This window is now active");
}

- (void)windowWillClose:(NSNotification *)notification {
//	AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
	
//	[appDelegate->arrayOfWindows removeObject:self.windowController];
//	[appDelegate->arrayOfWindows removeAllObjects];
}

@end
