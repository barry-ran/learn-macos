//
//  WindowDelegate.m
//  ActiveWindow
//
//  Created by barry on 2021/8/23.
//
#import <Cocoa/Cocoa.h>

#import "WindowDelegate.h"

@interface WindowDelegate ()

@property(weak) IBOutlet NSTextField* text;

@end

#define CF_RELEASE(p) \
  {                   \
    if (p) {          \
      CFRelease(p);   \
    }                 \
  }

CFDictionaryRef GetWindowInfoDict(CGWindowID windowID) {
    CFMutableArrayRef windowIds = CFArrayCreateMutable(nullptr, 0, nullptr);
    assert(windowIds != nullptr);

    CFArrayAppendValue(windowIds, reinterpret_cast<const void*>(windowID));
    CFArrayRef windowList = CGWindowListCreateDescriptionFromArray(windowIds);
  
    if (windowList == nullptr || CFArrayGetCount(windowList) < 1) {
        NSLog(@"CGWindowListCreateDescriptionFromArray fail, winId:%d", windowID);
        CF_RELEASE(windowIds);
        return nullptr;
    }

    auto ret = CFDictionaryCreateCopy(nullptr, reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(windowList, 0)));
    
    CF_RELEASE(windowIds);
    CF_RELEASE(windowList);
    
    return ret;
}

bool ActivateAppWindow(CGWindowID windowID) {
    auto winInfoDict = GetWindowInfoDict(windowID);

    if (winInfoDict == nullptr) {
        NSLog(@"GetWindowInfoDict fail");
        return false;
    }

    auto winPidRef = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(winInfoDict, kCGWindowOwnerPID));
    pid_t winPid;
    CFNumberGetValue(winPidRef, kCFNumberIntType, &winPid);

    NSRunningApplication* app = [NSRunningApplication runningApplicationWithProcessIdentifier:winPid];
    if (app == nil) {
        NSLog(@"runningApplicationWithProcessIdentifier fail");
        CF_RELEASE(winInfoDict)
        return false;
    }

    // (NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)
    BOOL isSuccess = [app activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
    // NSApplicationActivateAllWindows 在10.15以后某些app是不生效的，使用openApplicationAtURL来达到ActivateAllWindows的效果
    // https://github.com/frinkr/GlobalKey/blob/6f774bffc00d500d73dcbd9e2c3bf5b315437442/GlobalKeyLib/GKProxyAppMac.mm#L133
    if (isSuccess) {
        if (@available(macOS 10.15, *)) {
            NSWorkspaceOpenConfiguration * config = [NSWorkspaceOpenConfiguration configuration];
            config.allowsRunningApplicationSubstitution = FALSE;
            [[NSWorkspace sharedWorkspace] openApplicationAtURL:[app bundleURL] configuration:config completionHandler:nil];
        }
    }
    if (!isSuccess) {
        NSLog(@"active app window fail:%d", windowID);
        CF_RELEASE(winInfoDict)
    }
    
    CF_RELEASE(winInfoDict)

    return isSuccess;
}

@implementation WindowDelegate

- (IBAction)activeBtnClick:(id)sender
{
    if ([self.text.stringValue isEqual: @""]) {
        return;
    }
    
    NSLog(@"active window:%@", self.text.stringValue);
    ActivateAppWindow(self.text.intValue);
}
@end
