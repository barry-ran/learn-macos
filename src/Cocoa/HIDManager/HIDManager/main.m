//
//  main.m
//  HIDManager
//
//  Created by barry on 2020/6/3.
//  Copyright © 2020 barry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

static CFMutableDictionaryRef hu_CreateDeviceMatchingDictionary(UInt32 inUsagePage, UInt32 inUsage)
{
    // create a dictionary to add usage page/usages to
    //
    CFMutableDictionaryRef result=
        CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    if (!result) {
        fprintf(stderr, "%s: CFDictionaryCreateMutable failed.", __PRETTY_FUNCTION__);
        return result;
    }

    if (!inUsagePage) return NULL;

    // Add key for device type to refine the matching dictionary.
    //
    CFNumberRef pageCFNumberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &inUsagePage);
    if (!pageCFNumberRef) {
        fprintf(stderr, "%s: CFNumberCreate(usage page) failed.", __PRETTY_FUNCTION__);
        return NULL;
    }

    CFDictionarySetValue(result,CFSTR(kIOHIDDeviceUsagePageKey), pageCFNumberRef);
    CFRelease(pageCFNumberRef);

    // note: the usage is only valid if the usage page is also defined
    if (!inUsage) return NULL;
    
    CFNumberRef usageCFNumberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &inUsage);
    if (!usageCFNumberRef) {
        fprintf(stderr, "%s: CFNumberCreate(usage) failed.", __PRETTY_FUNCTION__);
        return NULL;
    }

    CFDictionarySetValue(result, CFSTR(kIOHIDDeviceUsageKey), usageCFNumberRef);
    CFRelease(usageCFNumberRef);

    return result;
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // 1. 创建IOHIDManagerRef
        IOHIDManagerRef managerRef = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
        if (CFGetTypeID(managerRef) != IOHIDManagerGetTypeID()) {
            NSLog(@"can't create manager");
            return -1;
        }

        // 2. 创建HID设备匹配规则数组，用来保存匹配规则
        CFMutableArrayRef matchingArrayRef = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        if (matchingArrayRef) {
            CFDictionaryRef matchingDictRef;
                
            // 3 创建Keyboard匹配规则
            matchingDictRef = hu_CreateDeviceMatchingDictionary(kHIDPage_GenericDesktop, kHIDUsage_GD_Keyboard);
            if (matchingDictRef) {
                // 4 将匹配规则加入匹配规则数组
                CFArrayAppendValue(matchingArrayRef, matchingDictRef);
                CFRelease(matchingDictRef); // and release it
            } else {
                fprintf(stderr, "%s: hu_CreateDeviceMatchingDictionary(keyboard) failed.", __PRETTY_FUNCTION__);
            }
                
            // 创建Keypad匹配规则
            matchingDictRef = hu_CreateDeviceMatchingDictionary(kHIDPage_GenericDesktop, kHIDUsage_GD_Keypad);
            if (matchingDictRef) {
                // 将匹配规则加入匹配规则数组
                CFArrayAppendValue(matchingArrayRef, matchingDictRef);
                CFRelease(matchingDictRef);
            } else {
                fprintf(stderr, "%s: hu_CreateDeviceMatchingDictionary(key pad) failed.", __PRETTY_FUNCTION__);
            }
            
        } else {
            fprintf(stderr, "%s: CFArrayCreateMutable failed.", __PRETTY_FUNCTION__);
        }
            
        
        // 5. 将匹配规则设置到managerRef
        IOHIDManagerSetDeviceMatchingMultiple(managerRef, matchingArrayRef);
        CFRelease(matchingArrayRef);
        
        // 6. 枚举匹配的HID设备信息
        CFSetRef device_set = IOHIDManagerCopyDevices(managerRef);
        CFIndex num_devices = CFSetGetCount(device_set);
        
        IOHIDDeviceRef *device_array = (IOHIDDeviceRef *)calloc(num_devices, sizeof(IOHIDDeviceRef));
        CFSetGetValues(device_set, (const void **)device_array);

        for (int i = 0; i < num_devices; i++) {
            IOHIDDeviceRef TmpDeviceRef = device_array[i];
            if (!TmpDeviceRef) {
                continue;
            }

            CFStringRef str = (CFStringRef)IOHIDDeviceGetProperty(TmpDeviceRef, CFSTR(kIOHIDSerialNumberKey));
            if (!str) {
                continue;
            }

            NSString *nsstrSerno = (__bridge NSString *)str;
            NSLog(@"serial: %@", nsstrSerno);
        }
        
        free(device_array);
        CFRelease(device_set);
        CFRelease(managerRef);
    }
    return 0;
}
