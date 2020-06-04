//
//  AppDelegate.m
//  checkUsb
//
//  Created by Young on 11/29/17.
//  Copyright © 2017 com.HY. All rights reserved.
//

#import "AppDelegate.h"
@interface AppDelegate ()

@end
@implementation AppDelegate : NSObject 

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
#pragma unused(sender)
    return YES;
}

- (IBAction)btcheckusb:(id)sender {
    unsigned short pidA,vidA,locA;
    vidA = HexToLong([[m_vid stringValue]UTF8String]);
    pidA = HexToLong([[m_pid stringValue]UTF8String]);
    locA = HexToLong([[m_locid stringValue]UTF8String]);
    int ret = CheckUSBHID(vidA,pidA,locA,2000);
    ret = GetUsbLocation(vidA,pidA);
    UInt32 locationID = GetUsbLocation(vidA,pidA);
    NSLog(@"Hub Address : 0x%08x",(unsigned int)locationID);
    NSLog(@"lll%ld",HexToLong("0x1d183000"));
    const char * v = GetUsbVersion(vidA,pidA);
    const char *s = GetUsbSerialNumber(vidA,pidA);
    [m_matchlocid setStringValue:[NSString stringWithFormat:@"0x%08x",(unsigned int)locationID]];
    [m_version setStringValue:[NSString stringWithUTF8String:v]];
    [m_serialnum setStringValue:[NSString stringWithUTF8String:s]];

}
- (IBAction)btlooppanel:(id)sender
{
    [looppanle makeKeyAndOrderFront:nil];
}

- (IBAction)btlookusbDev:(id)sender
{
    NSString * str = @"";
    NSMutableArray * arrlist = GetUSBDeviceListByDeviceName(str);
    [self btcleasr:nil];
    for (id str in arrlist) {
        if([str isKindOfClass:[NSString class]]){
            [self performSelectorOnMainThread:@selector(logOut:) withObject:str waitUntilDone:YES];
        }
    }
}


int DebugMsgCounter = 0;
-(void)logOut:(NSString*)msg
{
    //    DebugMsgCounter++;
    //    if (DebugMsgCounter > 10000) {
    //        [mLog setString:@""];
    //        DebugMsgCounter = 0;
    //    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    int length = 0;
    NSAttributedString *theString;
    NSRange theRange;
    
    NSString * str = [NSString stringWithFormat:@"%@===:%@\r",[dateFormatter stringFromDate:[NSDate date]],msg];
    theString = [[NSAttributedString alloc] initWithString:str];
    [[m_SerialPortView textStorage] appendAttributedString: theString];
    length = (int)[[m_SerialPortView textStorage] length];
    theRange = NSMakeRange(length, 0);
    [m_SerialPortView scrollRangeToVisible:theRange];
    [dateFormatter release];
    [theString release];
    [m_SerialPortView setNeedsDisplay:YES];
}


-(IBAction)btcleasr:(id)sender{
    [[m_SerialPortView textStorage] replaceCharactersInRange:NSMakeRange(0, [[m_SerialPortView textStorage] length]) withString:@""];
}
@end
