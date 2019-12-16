//
//  OpenGLView.m
//  opengl-macos
//
//  Created by Xavier Slattery on 13/2/18.
//  Copyright © 2018 Xavier Slattery. All rights reserved.
//

#import "OpenGLView.h"
#import <Opengl/gl3.h>

@implementation OpenGLView

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
	// Drawing code here.
	glClearColor(0, 1, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	[[self openGLContext] flushBuffer];
}

- (BOOL)acceptsFirstResponder { return YES; }
- (BOOL)mouseDownCanMoveWindow { return YES; }

- (void) keyDown: (NSEvent*)event {
	if ([event isARepeat] == NO) {
		unsigned int key = [event keyCode];
		NSLog(@"KeyDown");
	}
}

- (void) keyUp: (NSEvent*)event {
	unsigned int key = [event keyCode];
}

- (void)mouseMoved:(NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) mouseDragged: (NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) scrollWheel: (NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	[event deltaX];
	[event deltaY];
}

- (void) mouseDown: (NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) mouseUp: (NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) rightMouseDown: (NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) rightMouseUp: (NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) otherMouseDown: (NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) otherMouseUp: (NSEvent*)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) mouseEntered: (NSEvent*)event {
	
}

- (void) mouseExited: (NSEvent*)event {
	
}

@end
