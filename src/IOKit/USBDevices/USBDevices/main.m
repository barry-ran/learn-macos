//
//  main.m
//  USBDevices
//
//  Created by barry on 2020/6/4.
//  Copyright © 2020 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/usb/IOUSBLib.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <IOKit/IOCFPlugIn.h>

// https://developer.apple.com/library/archive/documentation/DeviceDrivers/Conceptual/AccessingHardware/AH_Intro/AH_Intro.html#//apple_ref/doc/uid/TP40002714

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        CFMutableDictionaryRef     matchingDict;
        kern_return_t            kr;
        
        // Set up the matching criteria for the devices we're interested in. The matching criteria needs to follow
        // the same rules as kernel drivers: mainly it needs to follow the USB Common Class Specification, pp. 6-7.
        // See also Technical Q&A QA1076 "Tips on USB driver matching on Mac OS X"
        // <http://developer.apple.com/qa/qa2001/qa1076.html>.
        // One exception is that you can use the matching dictionary "as is", i.e. without adding any matching
        // criteria to it and it will match every IOUSBDevice in the system. IOServiceAddMatchingNotification will
        // consume this dictionary reference, so there is no need to release it later on.
        
        // 可以选择匹配设备或者接口
        matchingDict = IOServiceMatching(kIOUSBDeviceClassName);    // Interested in instances of class
        // IOUSBDevice and its subclasses
        if (matchingDict == NULL) {
            fprintf(stderr, "IOServiceMatching returned NULL.\n");
            return -1;
        }
        
        // We are interested in all USB devices (as opposed to USB interfaces).  The Common Class Specification
        // tells us that we need to specify the idVendor, idProduct, and bcdDevice fields, or, if we're not interested
        // in particular bcdDevices, just the idVendor and idProduct.  Note that if we were trying to match an
        // IOUSBInterface, we would need to set more values in the matching dictionary (e.g. idVendor, idProduct,
        // bInterfaceNumber and bConfigurationValue.
        
        // 匹配规则的指定 https://developer.apple.com/library/archive/documentation/DeviceDrivers/Conceptual/USBBook/USBOverview/NaN#//apple_ref/doc/uid/TP40002644-BBIDGCHB
        
        CFNumberRef                numberRef;
        long value;
        // 如果不设置匹配规则，就查找所有
#if 0
        // 通过class subclass匹配查找hub（usb扩展）
        // class subclass详细描述 https://www.usb.org/defined-class-codes#anchor_BaseClass09h
        value = kUSBHubClass;
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &value);
        CFDictionarySetValue(matchingDict,
                             CFSTR(kUSBDeviceClass),
                             numberRef);
        CFRelease(numberRef);
        
        value = 0;
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &value);
        CFDictionarySetValue(matchingDict,
                             CFSTR(kUSBDeviceSubClass),
                             numberRef);
        CFRelease(numberRef);
#endif
        
#if 0
        // 通过vid pid匹配查找mac内置摄像头
        value = 0x05AC;
        // Create a CFNumber for the idVendor and set the value in the dictionary
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &value);
        CFDictionarySetValue(matchingDict,
                             CFSTR(kUSBVendorID),
                             numberRef);
        CFRelease(numberRef);
        
        value = 0x8514;
        // Create a CFNumber for the idProduct and set the value in the dictionary
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &value);
        CFDictionarySetValue(matchingDict,
                             CFSTR(kUSBProductID),
                             numberRef);
        CFRelease(numberRef);
#endif
        numberRef = NULL;
        value = 0;
        
        io_iterator_t iter;
        /* Now we have a dictionary, get an iterator.*/
        kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
        if (kr != KERN_SUCCESS)
        {
            return -1;
        }
        
        io_service_t device;
        /* iterate */
        while ((device = IOIteratorNext(iter)))
        {
            // 获取设备名称
            io_name_t deviceName;
            kr = IORegistryEntryGetName(device, deviceName);
            if(KERN_SUCCESS != kr) {
                deviceName [0] ='\0';
            }
            
            // vid
            int vid = 0;
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(device, &dict, kCFAllocatorDefault, kNilOptions) == KERN_SUCCESS) {
                CFNumberRef num = (CFNumberRef)CFDictionaryGetValue(dict, CFSTR(kUSBVendorID));
                if (num) {
                    CFNumberGetValue(num, kCFNumberIntType, &vid);
                    CFRelease(num);
                }
            }
            
            // pid
            int pid = 0;
            dict = NULL;
            if (IORegistryEntryCreateCFProperties(device, &dict, kCFAllocatorDefault, kNilOptions) == KERN_SUCCESS) {
              CFNumberRef num = (CFNumberRef)CFDictionaryGetValue(dict, CFSTR(kUSBProductID));
              if (num) {
                  CFNumberGetValue(num, kCFNumberIntType, &pid);
                  CFRelease(num);
              }
            }
            
            // 获取序列号
            NSString *serial;
            dict = NULL;
            if (IORegistryEntryCreateCFProperties(device, &dict, kCFAllocatorDefault, kNilOptions) == KERN_SUCCESS) {
              CFTypeRef obj = CFDictionaryGetValue(dict, CFSTR(kUSBSerialNumberString));
              if (obj) {
                  serial = (__bridge NSString *)(CFStringRef)obj;
              }
            }
            
            printf("vid: 0x%0x pid: 0x%0x kUSBSerialNumberString: %s deviceName：%s\n", vid, pid, serial.UTF8String, deviceName);
            
            // 获取locationID需要通过interface
            IOUSBDeviceInterface    **deviceInterface = NULL;
            IOCFPlugInInterface    **plugInInterface = NULL;
            SInt32                score;
            HRESULT             res;
            UInt32            locationID;
            
            // Now, get the locationID of this device. In order to do this, we need to create an IOUSBDeviceInterface
            // for our device. This will create the necessary connections between our userland application and the
            // kernel object for the USB Device.
            // 先创建plugInInterface
            kr = IOCreatePlugInInterfaceForService(device, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
                                                   &plugInInterface, &score);

            if ((kIOReturnSuccess != kr) || !plugInInterface) {
                fprintf(stderr, "IOCreatePlugInInterfaceForService returned 0x%08x. 0x%08x\n", kr, kIOReturnNoResources);
                continue;
            }

            // 通过plugin interface查找device interface.
            res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                                     (LPVOID*)&deviceInterface);
            
            // Now done with the plugin interface.
            (*plugInInterface)->Release(plugInInterface);
                        
            if (res || deviceInterface == NULL) {
                fprintf(stderr, "QueryInterface returned %d.\n", (int) res);
                continue;
            }

            // Now that we have the IOUSBDeviceInterface, we can call the routines in IOUSBLib.h.
            // In this case, fetch the locationID. The locationID uniquely identifies the device
            // and will remain the same, even across reboots, so long as the bus topology doesn't change.
            
            kr = (*deviceInterface)->GetLocationID(deviceInterface, &locationID);
            if (KERN_SUCCESS != kr) {
                fprintf(stderr, "GetLocationID returned 0x%08x.\n", kr);
                continue;
            } else {
                fprintf(stderr, "Location ID: 0x%0x\n\n", locationID);
            }
            
            /* And free the reference taken before continuing to the next item */
            IOObjectRelease(device);
        }
        
        /* Done, release the iterator */
        IOObjectRelease(iter);
        return 0;
    }
    return 0;
}
