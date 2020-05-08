//
//  main.m
//  AudioDevice
//
//  Created by barry on 2020/4/22.
//  Copyright © 2020 barry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        AudioObjectPropertyAddress propertyAddress = {
            kAudioHardwarePropertyDevices,
            kAudioObjectPropertyScopeGlobal,
            kAudioObjectPropertyElementMaster
        };
        
        UInt32 dataSize = 0;
        OSStatus status = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
        if(status != kAudioHardwareNoError) {
            NSLog(@"AudioObjectGetPropertyDataSize (kAudioHardwarePropertyDevices) failed: %i", status);
            return 0;
        }
        
        UInt32 deviceCount = (UInt32)(dataSize/sizeof(AudioDeviceID));
        
        NSLog(@"audio device count:%i", deviceCount);
        
        AudioDeviceID *audioDevices = (AudioDeviceID *)(calloc(dataSize,1));
        if(NULL == audioDevices) {
            NSLog (@"Unable to allocate memory");
            return 0;
        }
        
        status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, audioDevices);
        if(status != kAudioHardwareNoError) {
            fprintf(stderr, "AudioObjectGetPropertyData (kAudioHardwarePropertyDevices) failed: %i\n", status);
            free(audioDevices);
            audioDevices = NULL;
            return 0;
        }
        
        for(UInt32 i = 0; i < deviceCount; ++i) {
            // Query device UID
            CFStringRef deviceUID = NULL;
            dataSize = sizeof(deviceUID);
            propertyAddress.mSelector = kAudioDevicePropertyDeviceUID;
            status = AudioObjectGetPropertyData(audioDevices[i], &propertyAddress, 0, NULL, &dataSize, &deviceUID);
            if(status != kAudioHardwareNoError) {
                NSLog (@"AudioObjectGetPropertyData (kAudioDevicePropertyDeviceUID) failed: %i", status);
                continue;
            }
            
            NSLog(@"device uid: %@", deviceUID);
            
            CFStringRef deviceMUID = NULL;
            dataSize = sizeof(deviceMUID);
            propertyAddress.mSelector = kAudioDevicePropertyModelUID;
            status = AudioObjectGetPropertyData(audioDevices[i], &propertyAddress, 0, NULL, &dataSize, &deviceMUID);
            if(status != kAudioHardwareNoError) {
                NSLog (@"AudioObjectGetPropertyData (kAudioDevicePropertyModelUID) failed: %i", status);
            }
            
            NSLog(@"device muid: %@", deviceMUID);
            
            
            
            // For fun, let's do a reverse lookup for device ID
            AudioDeviceID ourDeviceID;
            UInt32 dataSize = sizeof(ourDeviceID);
            propertyAddress.mSelector = kAudioHardwarePropertyTranslateUIDToDevice;
            // Just for fun, get the default input device and compare results
            status = AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                                &propertyAddress,
                                                sizeof(deviceUID),
                                                &deviceUID,
                                                &dataSize,
                                                &ourDeviceID);
            if (kAudioHardwareNoError != status) {
                NSLog (@"Can't reverse lookup audio id");
            }
            
            // macos 10.11 ourDeviceID != audioDevices[i]
            if (ourDeviceID != audioDevices[i]) {
                NSLog (@"Reversed audio id %d Not equal to audioDevice[] of %d", ourDeviceID, audioDevices[i]);
            } else {
                NSLog (@"audio id: %d", ourDeviceID);
            }
        }
    }
    return 0;
}
