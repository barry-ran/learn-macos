//
//  AppDelegate.m
//  opengl-macos
//
//  Created by Xavier Slattery on 13/2/18.
//  Copyright © 2018 Xavier Slattery. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

- (IBAction)newWindow:(id)sender;

@end

@implementation AppDelegate

- (void)awakeFromNib {
//	arrayOfWindows = [[NSMutableArray alloc]init];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	[self newWindow:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

- (IBAction)newWindow:(id)sender {
	NSWindowController *windowController = [[NSWindowController alloc] initWithWindowNibName:@"Window"];
	[windowController showWindow:self];
}

@end
