//
//  main.m
//  VideoDevice
//
//  Created by barry on 2020/6/3.
//  Copyright © 2020 barry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMediaIO/CMIOHardware.h>
#import <IOKit/audio/IOAudioTypes.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        CMIOObjectPropertyAddress propertyAddress = {
            kCMIOHardwarePropertyDevices,
            kCMIOObjectPropertyScopeGlobal,
            kCMIOObjectPropertyElementMaster
        };
        
        UInt32 dataSize = 0;
        OSStatus status = CMIOObjectGetPropertyDataSize(kCMIOObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
        if(status != kCMIOHardwareNoError) {
            NSLog(@"CMIOObjectGetPropertyDataSize (kCMIOHardwarePropertyDevices) failed: %i", status);
            return 0;
        }
        
        UInt32 deviceCount = (UInt32)(dataSize/sizeof(CMIOObjectID));
        
        NSLog(@"video device count:%i", deviceCount);
        
        CMIOObjectID *videoDevices = (CMIOObjectID *)(calloc(dataSize,1));
        if(NULL == videoDevices) {
            NSLog (@"Unable to allocate memory");
            return 0;
        }
        UInt32 used = 0;
        status = CMIOObjectGetPropertyData(kCMIOObjectSystemObject, &propertyAddress, 0, NULL, dataSize, &used, videoDevices);
        if(status != kCMIOHardwareNoError) {
            fprintf(stderr, "CMIOObjectGetPropertyData (kCMIOHardwarePropertyDevices) failed: %i\n", status);
            free(videoDevices);
            videoDevices = NULL;
            return 0;
        }
        
        for(UInt32 i = 0; i < deviceCount; ++i) {
            
            CFStringRef deviceName = NULL;
            dataSize = sizeof(deviceName);
            propertyAddress.mSelector = kCMIOObjectPropertyName;
            status = CMIOObjectGetPropertyData(videoDevices[i], &propertyAddress, 0, NULL, dataSize, &used, &deviceName);
            if(status != kCMIOHardwareNoError) {
                NSLog (@"CMIOObjectGetPropertyData (kCMIOObjectPropertyName) failed: %i", status);
                continue;
            }
            
            NSLog(@"*******device name: %@", deviceName);
            
            continue;
            
            
            
            // Query device UID
            CFStringRef deviceUID = NULL;
            dataSize = sizeof(deviceUID);
            propertyAddress.mSelector = kCMIODevicePropertyDeviceUID;
            status = CMIOObjectGetPropertyData(videoDevices[i], &propertyAddress, 0, NULL, dataSize, &used, &deviceUID);
            if(status != kCMIOHardwareNoError) {
                NSLog (@"CMIOObjectGetPropertyData (kCMIODevicePropertyDeviceUID) failed: %i", status);
                continue;
            }
            
            NSLog(@"device uid: %@", deviceUID);
            
            CFStringRef deviceMUID = NULL;
            dataSize = sizeof(deviceMUID);
            propertyAddress.mSelector = kCMIODevicePropertyModelUID;
            status = CMIOObjectGetPropertyData(videoDevices[i], &propertyAddress, 0, NULL, dataSize, &used, &deviceMUID);
            if(status != kCMIOHardwareNoError) {
                NSLog (@"AudioObjectGetPropertyData (kAudioDevicePropertyModelUID) failed: %i", status);
            }
            
            NSLog(@"device muid: %@", deviceMUID);
        }
    }
    return 0;
}
