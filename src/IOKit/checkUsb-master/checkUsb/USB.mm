
//
//  USB.cpp
//  Global
//
//  Created by Ryan on 13-2-20.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#import <Cocoa/Cocoa.h>

#define kMyVendorID		0x9011	//0x0424//1351
#define kMyProductID	0x2514	//0x2514//8193

#define FT4232_VID  0x0403
#define FT4232_PID  0x6011
#define TG_CMD_BUFFER_LEN 64

BOOL bScanAllDevice = TRUE;


typedef struct MyPrivateData {
    io_object_t				notification;
    IOUSBDeviceInterface	**deviceInterface;
    CFStringRef				deviceName;
    UInt32					locationID;
} MyPrivateData;

static IONotificationPortRef	gNotifyPort;
static io_iterator_t			gAddedIter;

#define kDeviceName     @"device_name"
#define kLocationID     @"location_id"

struct Context {
    BOOL bScanAlldevice;
    NSMutableArray * arrDevList;
};

//================================================================================================
//
//	DeviceNotification
//
//	This routine will get called whenever any kIOGeneralInterest notification happens.  We are
//	interested in the kIOMessageServiceIsTerminated message so that's what we look for.  Other
//	messages are defined in IOMessage.h.
//
//================================================================================================
void DeviceNotification(void *refCon, io_service_t service, natural_t messageType, void *messageArgument)
{
    kern_return_t	kr;
    MyPrivateData	*privateDataRef = (MyPrivateData *) refCon;
    
    if (messageType == kIOMessageServiceIsTerminated) {
        fprintf(stderr, "Device removed.\n");
        
        // Dump our private data to stderr just to see what it looks like.
        fprintf(stderr, "privateDataRef->deviceName: ");
		CFShow(privateDataRef->deviceName);
		fprintf(stderr, "privateDataRef->locationID: 0x%x.\n\n", (unsigned int)privateDataRef->locationID);
        
        // Free the data we're no longer using now that the device is going away
        CFRelease(privateDataRef->deviceName);
        
        if (privateDataRef->deviceInterface) {
            kr = (*privateDataRef->deviceInterface)->Release(privateDataRef->deviceInterface);
        }
        
        kr = IOObjectRelease(privateDataRef->notification);
        
        free(privateDataRef);
    }
}

//================================================================================================
//
//	DeviceAdded
//
//	This routine is the callback for our IOServiceAddMatchingNotification.  When we get called
//	we will look at all the devices that were added and we will:
//
//	1.  Create some private data to relate to each device (in this case we use the service's name
//	    and the location ID of the device
//	2.  Submit an IOServiceAddInterestNotification of type kIOGeneralInterest for this device,
//	    using the refCon field to store a pointer to our private data.  When we get called with
//	    this interest notification, we can grab the refCon and access our private data.
//
//================================================================================================
UInt32 usbAddress=0;
char serialnumber[128];
char USBVersion[128];
static bool getUSBVersion(io_service_t hidDevice,io_name_t version)
{
    kern_return_t result;
    CFMutableDictionaryRef hidProperties = 0;
    result = IORegistryEntryCreateCFProperties(hidDevice, &hidProperties, kCFAllocatorSystemDefault, kNilOptions);
    if ((result == KERN_SUCCESS) && hidProperties)
    {
        CFNumberRef versionRef = (CFNumberRef)CFDictionaryGetValue(hidProperties, CFSTR("bcdDevice"));
        if (versionRef)
        {
            int ver=0;
            CFNumberGetValue(versionRef, kCFNumberIntType, &ver);
            CFRelease(versionRef);
            int h=ver/0x100;
            int w=ver%0x100;
            sprintf(version, "%x.%02x",h,w);
            return true;
        }
    }
    return false;
}
//add for get usb serial number

static void getStringDescriptor(IOUSBDeviceInterface182 **deviceInterface,
                                uint8_t index,
                                io_name_t stringBuffer)
{
    io_name_t buffer;
    memset(stringBuffer, 0, 128);
    IOUSBDevRequest request = {
        .bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice),
        .bRequest = kUSBRqGetDescriptor,
        .wValue = static_cast<UInt16>((kUSBStringDesc << 8) | index),
        .wIndex = 0x409,
        .wLength = sizeof(buffer),
        .pData = buffer
    };
    
    kern_return_t result;
    result = (*deviceInterface)->DeviceRequest(deviceInterface, &request);
    if (result != KERN_SUCCESS) {
        return;
    }
    
    uint32_t count = 0;
    for (uint32_t j = 2; j < request.wLenDone; j += 2) {
        stringBuffer[count++] = buffer[j];
    }
    stringBuffer[count] = '\0';
}

static void getUDID(io_service_t device, io_name_t udidBuffer)
{
    kern_return_t result;
    
    SInt32 score;
    IOCFPlugInInterface **plugin = NULL;
    result = IOCreatePlugInInterfaceForService(device,
                                               kIOUSBDeviceUserClientTypeID,
                                               kIOCFPlugInInterfaceID,
                                               &plugin,
                                               &score);
    if (result != KERN_SUCCESS) {
        return;
    }
    
    IOUSBDeviceInterface182 **deviceInterface = NULL;
    result = (*plugin)->QueryInterface(plugin,
                                       CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID182),
                                       (void **)&deviceInterface);
    if (result != KERN_SUCCESS) {
        IODestroyPlugInInterface(plugin);
        return;
    }
    IODestroyPlugInInterface(plugin);
    
    UInt8 index;
    (*deviceInterface)->USBGetSerialNumberStringIndex(deviceInterface, &index);
    getStringDescriptor(deviceInterface, index, udidBuffer);
}

long HexToLong(const char*stringValue)
{
    Byte  pbuf[TG_CMD_BUFFER_LEN];
    bzero(pbuf, TG_CMD_BUFFER_LEN);
    
    char *pdata = (char *)stringValue;
    long len = strlen(pdata);
    memcpy(pbuf, pdata, len);
    
    int offset = 0;
    long result = 0;
    int temp = 0;
    
    
    while(pbuf[offset] != '\0')
    {
        switch (pbuf[offset]) {
            case '0':
                temp = 0x00;
                break;
            case '1':
                temp = 0x01;
                break;
            case '2':
                temp = 0x02;
                break;
            case '3':
                temp = 0x03;
                break;
            case '4':
                temp = 0x04;
                break;
            case '5':
                temp = 0x05;
                break;
            case '6':
                temp = 0x06;
                break;
            case '7':
                temp = 0x07;
                break;
            case '8':
                temp = 0x08;
                break;
            case '9':
                temp = 0x09;
                break;
            case 'A':
            case 'a':
                temp = 0x0A;
                break;
            case 'B':
            case 'b':
                temp = 0x0B;
                break;
            case 'C':
            case 'c':
                temp = 0x0C;
                break;
            case 'D':
            case 'd':
                temp = 0x0D;
                break;
            case 'E':
            case 'e':
                temp = 0x0E;
                break;
            case 'F':
            case 'f':
                temp = 0x0F;
                break;
            case ' ':
                break;
            default:
                break;
        }
        result += temp * pow(16, len - 1 - offset);
        offset++;
    }
    
    return result;
}

const char *ToHex(uint16_t tmpid)
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return [str UTF8String];
}
void DeviceAdded(void *refCon, io_iterator_t iterator)
{
    kern_return_t		kr;
    io_service_t		usbDevice;
    IOCFPlugInInterface	**plugInInterface = NULL;
    SInt32				score;
    HRESULT 			res;
    
    Context * pContext = (Context *)refCon;
    
    while ((usbDevice = IOIteratorNext(iterator))) {
        io_name_t		deviceName;
        CFStringRef		deviceNameAsCFString;	
        MyPrivateData	*privateDataRef = NULL;
        UInt32			locationID;
        char udidBuffer[128];
        char version[128];

        printf("Device added.\n");
        
        // Add some app-specific information about this device.
        // Create a buffer to hold the data.
        privateDataRef = (MyPrivateData *)malloc(sizeof(MyPrivateData));
        bzero(privateDataRef, sizeof(MyPrivateData));
        
        // Get the USB device's name.
        kr = IORegistryEntryGetName(usbDevice, deviceName);
		if (KERN_SUCCESS != kr) {
            deviceName[0] = '\0';
        }
        
        deviceNameAsCFString = CFStringCreateWithCString(kCFAllocatorDefault, deviceName, 
                                                         kCFStringEncodingASCII);
        
        // Dump our data to stderr just to see what it looks like.
        fprintf(stderr, "deviceName: ");
        CFShow(deviceNameAsCFString);
        
        // Save the device's name to our private data.        
        privateDataRef->deviceName = deviceNameAsCFString;
        
        // Now, get the locationID of this device. In order to do this, we need to create an IOUSBDeviceInterface 
        // for our device. This will create the necessary connections between our userland application and the 
        // kernel object for the USB Device.
        kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
                                               &plugInInterface, &score);
        
        if ((kIOReturnSuccess != kr) || !plugInInterface) {
            fprintf(stderr, "IOCreatePlugInInterfaceForService returned 0x%08x.\n", kr);
            continue;
        }
        
        // Use the plugin interface to retrieve the device interface.
        res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                                 (LPVOID*) &privateDataRef->deviceInterface);
        
        // Now done with the plugin interface.
        (*plugInInterface)->Release(plugInInterface);
        
        if (res || privateDataRef->deviceInterface == NULL) {
            fprintf(stderr, "QueryInterface returned %d.\n", (int) res);
            continue;
        }
        
        // Now that we have the IOUSBDeviceInterface, we can call the routines in IOUSBLib.h.
        // In this case, fetch the locationID. The locationID uniquely identifies the device
        // and will remain the same, even across reboots, so long as the bus topology doesn't change.
        
        kr = (*privateDataRef->deviceInterface)->GetLocationID(privateDataRef->deviceInterface, &locationID);
        if (KERN_SUCCESS != kr) {
            fprintf(stderr, "GetLocationID returned 0x%08x.\n", kr);
            continue;
        }
        else {
            BOOL bScanAllDevice = *(BOOL *)refCon;
            if (bScanAllDevice)
            {
                //                if (!arrDevice) arrDevice = [NSMutableArray array];
                //                [arrDevice addObject:[NSString stringWithFormat:@"0x%lx",locationID]];
            }
            else {
                //determin this hub has connect device or not
                getUSBVersion(usbDevice,version);
                getUDID(usbDevice,udidBuffer);
                usbAddress = locationID;
                strcpy(serialnumber, udidBuffer);
                strcpy(USBVersion, version);
                return;
            }
            fprintf(stderr, "Location ID: 0x%x\n\n", (unsigned int)locationID);
            
            
            const char * pName = CFStringGetCStringPtr(deviceNameAsCFString, kCFStringEncodingUTF8);
            if (!pName) pName = "";
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:pName],kDeviceName,[NSNumber numberWithUnsignedInt:locationID], kLocationID,nil];
            //[arrDeviceList addObject:dic];
            [pContext->arrDevList addObject:dic];
        }
        
        privateDataRef->locationID = locationID;
        
        // Register for an interest notification of this device being removed. Use a reference to our
        // private data as the refCon which will be passed to the notification callback.
        kr = IOServiceAddInterestNotification(gNotifyPort,						// notifyPort
											  usbDevice,						// service
											  kIOGeneralInterest,				// interestType
											  DeviceNotification,				// callback
											  privateDataRef,					// refCon
											  &(privateDataRef->notification)	// notification
											  );
        
        if (KERN_SUCCESS != kr) {
            printf("IOServiceAddInterestNotification returned 0x%08x.\n", kr);
        }
        
        // Done with this USB device; release the reference added by IOIteratorNext
        kr = IOObjectRelease(usbDevice);
    }
}


//int ScanDevice(long VID,long PID,BOOL bScanAllDevice)
int ScanDevice(long VID,long PID,void * context)
{
    CFMutableDictionaryRef 	matchingDict;
    CFNumberRef				numberRef;
    kern_return_t			kr;
    long					usbVendor = VID;
    long					usbProduct = PID;
    
    Context * pContext = (Context *)context;
    BOOL bScanAllDevice = pContext->bScanAlldevice;
    
    fprintf(stderr, "Looking for devices matching vendor ID=%ld and product ID=%ld.\n", usbVendor, usbProduct);
    
    // Set up the matching criteria for the devices we're interested in. The matching criteria needs to follow
    // the same rules as kernel drivers: mainly it needs to follow the USB Common Class Specification, pp. 6-7.
    // See also Technical Q&A QA1076 "Tips on USB driver matching on Mac OS X" 
	// <http://developer.apple.com/qa/qa2001/qa1076.html>.
    // One exception is that you can use the matching dictionary "as is", i.e. without adding any matching 
    // criteria to it and it will match every IOUSBDevice in the system. IOServiceAddMatchingNotification will 
    // consume this dictionary reference, so there is no need to release it later on.
    
    matchingDict = IOServiceMatching(kIOUSBDeviceClassName);	// Interested in instances of class
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
    
    if (!bScanAllDevice)
    {
        // Create a CFNumber for the idVendor and set the value in the dictionary
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor);
        CFDictionarySetValue(matchingDict, 
                             CFSTR(kUSBVendorID), 
                             numberRef);
        CFRelease(numberRef);
        
        // Create a CFNumber for the idProduct and set the value in the dictionary
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbProduct);
        CFDictionarySetValue(matchingDict, 
                             CFSTR(kUSBProductID), 
                             numberRef);
        CFRelease(numberRef);
        numberRef = NULL;
    }
    
    
    // Create a notification port and add its run loop event source to our run loop
    // This is how async notifications get set up.
    
    gNotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
    //    runLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
    
    //    gRunLoop = CFRunLoopGetCurrent();
    //    CFRunLoopAddSource(gRunLoop, runLoopSource, kCFRunLoopDefaultMode);
    
    // Now set up a notification to be called when a device is first matched by I/O Kit.
    kr = IOServiceAddMatchingNotification(gNotifyPort,					// notifyPort
                                          kIOFirstMatchNotification,	// notificationType
                                          matchingDict,					// matching
                                          DeviceAdded,					// callback
                                          context,				// refCon
                                          &gAddedIter					// notification
                                          );
    
    // Iterate once to get already-present devices and arm the notification    
    //DeviceAdded(&bScanAllDevice, gAddedIter);	
    DeviceAdded(context, gAddedIter);
    
    // Start the run loop. Now we'll receive notifications.
    fprintf(stderr, "Starting run loop.\n\n");
    //    CFRunLoopRun();
    
    // We should never get here
    //    fprintf(stderr, "Unexpectedly back from CFRunLoopRun()!\n");
    return 0;
}
static kern_return_t findUSBParent(io_registry_entry_t child, io_registry_entry_t* usbDevice) {
    kern_return_t kr;
    io_registry_entry_t parent;
    io_name_t		deviceName;
    kr = IORegistryEntryGetParentEntry(child, kIOUSBPlane, &parent);
    if (KERN_SUCCESS != kr) {
        return kr;
    } else {
        kr = IORegistryEntryGetName(parent, deviceName);
        if (KERN_SUCCESS != kr) {
            deviceName[0] = '\0';
        }
        NSLog(@"deviceName:%s",deviceName);
        io_name_t       parentClass;
        kr = IOObjectGetClass(parent, parentClass);
        if (KERN_SUCCESS != kr) {
            return kr;
        }
        if (strcmp(parentClass, "IOUSBDevice") == 0) {
            *usbDevice = parent;
            return KERN_SUCCESS;
        }
        kr = findUSBParent(parent, usbDevice);
        IOObjectRelease(parent);
        return kr;
    }
    
}

unsigned long getUSBDevice(void *refCon, io_iterator_t iterator,int port,long Parent_HabVid,long Parent_HabPid)
{
    kern_return_t		kr;
    io_service_t		usbDevice;
    io_name_t       DeviceClassName;
    
    Context * pContext = (Context *)refCon;
    [pContext->arrDevList removeAllObjects];
    
    while ((usbDevice = IOIteratorNext(iterator)))
    {
        kr = IOObjectGetClass(usbDevice, DeviceClassName);
        if (KERN_SUCCESS != kr) {
            continue;
        }
        if (strcmp(DeviceClassName, "IOUSBDevice") != 0) {
            continue;
        }
        bool isParent=(Parent_HabVid>0 && Parent_HabPid>0);
        if (port<0 && !isParent)
        {
            [pContext->arrDevList addObject:[NSNumber numberWithUnsignedInteger:usbDevice]];
            continue;
        }
        if(!isParent)
        {
            Parent_HabVid=-1;
            Parent_HabPid=-1;
        }
        if(port<0)
        {
            port=-1;
        }
        int current_port=-1;
        int current_parentVid=-1;
        int current_parentPid=-1;
        kern_return_t result;
        CFMutableDictionaryRef hidProperties = 0;
        NSDictionary *currentListing;
        if (port>=0)
        {
            result = IORegistryEntryCreateCFProperties(usbDevice, &hidProperties, kCFAllocatorSystemDefault, kNilOptions);
            if ((result == KERN_SUCCESS) && hidProperties)
            {
                currentListing = CFBridgingRelease(hidProperties);
                NSNumber *number=[currentListing objectForKey:@"PortNum"];
                //CFRelease(hidProperties);
                if (number!=nil)
                {
                    current_port=[number intValue];
                }
            }
        }
        if(isParent)
        {
            io_service_t		parentusbDevice;
            kr = findUSBParent(usbDevice,&parentusbDevice);
            if (KERN_SUCCESS==kr)
            {
                result = IORegistryEntryCreateCFProperties(parentusbDevice, &hidProperties, kCFAllocatorSystemDefault, kNilOptions);
                if ((result == KERN_SUCCESS) && hidProperties)
                {
                    currentListing = CFBridgingRelease(hidProperties);
                    NSNumber *numbervid=[currentListing objectForKey:@"idVendor"];
                    NSNumber *numberpid=[currentListing objectForKey:@"idProduct"];
                    //CFRelease(hidProperties);
                    if (numbervid && numberpid) {
                        current_parentVid=[numbervid intValue];
                        current_parentPid=[numberpid intValue];
                    }
                }
                kr = IOObjectRelease(parentusbDevice);
            }
            
        }
        if (current_port==port && current_parentVid==Parent_HabVid
            && current_parentPid==Parent_HabPid)
        {
            [pContext->arrDevList addObject:[NSNumber numberWithUnsignedInteger:usbDevice]];
        }
        //        MyPrivateData	*privateDataRef = NULL;
        //
        //        kr = IOServiceAddInterestNotification(gNotifyPort,						// notifyPort
        //                                              usbDevice,						// service
        //                                              kIOGeneralInterest,				// interestType
        //                                              DeviceNotification,				// callback
        //                                              privateDataRef,					// refCon
        //                                              &(privateDataRef->notification)	// notification
        //                                              );
        //
        //        if (KERN_SUCCESS != kr) {
        //            printf("IOServiceAddInterestNotification returned 0x%08x.\n", kr);
        //        }
        kr = IOObjectRelease(usbDevice);
    }
    return [pContext->arrDevList count];
}
int ScanUSBDevice(long VID,long PID,void * context,int port=-1,long Parent_HabVid=-1,long Parent_HabPid=-1)
{
    CFMutableDictionaryRef 	matchingDict;
    CFNumberRef				numberRef;
    kern_return_t			kr;
    long					usbVendor = VID;
    long					usbProduct = PID;
    
    Context * pContext = (Context *)context;
    BOOL bScanAllDevice = pContext->bScanAlldevice;
    
    
    matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    if (matchingDict == NULL) {
        fprintf(stderr, "IOServiceMatching returned NULL.\n");
        return -1;
    }
    
    if (!bScanAllDevice)
    {
        // Create a CFNumber for the idVendor and set the value in the dictionary
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor);
        CFDictionarySetValue(matchingDict,
                             CFSTR(kUSBVendorID),
                             numberRef);
        CFRelease(numberRef);
        
        // Create a CFNumber for the idProduct and set the value in the dictionary
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbProduct);
        CFDictionarySetValue(matchingDict,
                             CFSTR(kUSBProductID),
                             numberRef);
        CFRelease(numberRef);
        numberRef = NULL;
    }
    gNotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
    
    kr = IOServiceAddMatchingNotification(gNotifyPort,					// notifyPort
                                          kIOFirstMatchNotification,	// notificationType
                                          matchingDict,					// matching
                                          DeviceAdded,					// callback
                                          context,				// refCon
                                          &gAddedIter					// notification
                                          );
    
    //DeviceAdded(context, gAddedIter);
    
    return (int)getUSBDevice(context, gAddedIter,port,Parent_HabVid,Parent_HabPid);
}
UInt32 GetUsbCount(long vid,long pid,int port=-1,long Parent_HabVid=-1,long Parent_HabPid=-1)
{
    Context context;
    context.bScanAlldevice = 0;
    context.arrDevList = [NSMutableArray array];
    unsigned long n=ScanUSBDevice(vid, pid, &context,port,Parent_HabVid,Parent_HabPid);
    //    if (n>0) {
    //        for (NSNumber  in context.arrDevList) {
    //            <#statements#>
    //        }
    //    }
    return (UInt32)n;
}
//usb operation
UInt32 GetUsbLocation(long vid,long pid)
{
    Context context;
    context.bScanAlldevice = 0;
    context.arrDevList = [NSMutableArray array];
    usbAddress = 0;
    ScanDevice(vid, pid, &context);
    return usbAddress;
}

char *GetUsbVersion(long vid,long pid)
{
    Context context;
    context.bScanAlldevice = 0;
    context.arrDevList = [NSMutableArray array];
    memset(USBVersion,0,128);
    ScanDevice(vid, pid, &context);
    return USBVersion;
}

char* GetUsbSerialNumber(long vid,long pid)
{
    Context context;
    memset(serialnumber,0,128);
    context.bScanAlldevice = 0;
    context.arrDevList = [NSMutableArray array];
    ScanDevice(vid, pid, &context);
    return serialnumber;
}

int CheckUsb(unsigned long usb_address)    //1: usb connecting, 0: usb disconnect.
{
    Context context;
    context.bScanAlldevice = 1;
    context.arrDevList = [NSMutableArray array];
    ScanDevice(0, 0, &context);
    for (NSDictionary * dic in context.arrDevList)
    {
        uint32 locationid = [[dic valueForKey:kLocationID] unsignedIntValue];
        if (locationid==usb_address)
        {
            NSLog(@"Find the special devie! with name : %@\r\n",[dic valueForKey:kDeviceName]);
            return 1;
        }
    }
    printf("Couldn't find the speccial device!\r\n");
    return 0;
}
int CheckUsbDevice(long vid,long pid)
{
    UInt32 locationID=GetUsbLocation(vid,pid);
    return CheckUsb(locationID);
}

int WaitUsb(unsigned long usb_address,int timeout)    //waiting for a usb device conntected
{
    NSTimeInterval timeStart = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval now=0;
    while (1) {
        now = [NSDate timeIntervalSinceReferenceDate];
        if ((now-timeStart)>(timeout/1000))   //time out
        {
            return -1;
        }
        
        if ([[NSThread currentThread] isCancelled])
        {
            return -2;  //cancel
        }
        
        if (CheckUsb(usb_address)) return 0;    //oK
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        [NSThread sleepForTimeInterval:0.01];
    }
    return 0;
}

typedef struct MyUSBData {
    //    NSCondition *cond;
    dispatch_semaphore_t    semaphore=NULL;
    UInt16					vendorid=0;
    UInt16					productid=0;
    UInt32					locationID=0;
    UInt32					r_locationID=0;
    IONotificationPortRef	NotifyPort;
    io_iterator_t			AddedIter;
    CFRunLoopRef			RunLoop;
} MyUSBData;

void ScanUSB(void *refCon, io_iterator_t iterator)
{
    kern_return_t		kr;
    io_service_t		usbDevice;
    IOCFPlugInInterface	**plugInInterface = NULL;
    SInt32				score;
    HRESULT 			res;
    MyUSBData *usbdata=(MyUSBData*)refCon;
    while ((usbDevice = IOIteratorNext(iterator))) {
        
        UInt32 location_t=0;
        UInt16 pid_t=0;
        UInt16 vid_t=0;
        IOUSBDeviceInterface	**deviceInterface;
        kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
                                               &plugInInterface, &score);
        
        if ((kIOReturnSuccess != kr) || !plugInInterface) {
            fprintf(stderr, "IOCreatePlugInInterfaceForService returned 0x%08x.\n", kr);
            continue;
        }
        res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                                 (LPVOID*) &deviceInterface);
        
        // Now done with the plugin interface.
        (*plugInInterface)->Release(plugInInterface);
        
        if (res || deviceInterface == NULL) {
            fprintf(stderr, "QueryInterface returned %d.\n", (int) res);
            continue;
        }
        (*deviceInterface)->GetLocationID (deviceInterface, &location_t);
        (*deviceInterface)->GetDeviceVendor(deviceInterface, &vid_t);
        (*deviceInterface)->GetDeviceProduct(deviceInterface, &pid_t);
        (*deviceInterface)->Release(deviceInterface);
        // Done with this USB device; release the reference added by IOIteratorNext
        kr = IOObjectRelease(usbDevice);
        printf("\n\nusbdata->locationID=%08x\n\n",location_t);
        printf("\n\nusbdata->VID=%08x\n\n",vid_t);
        printf("\n\nusbdata->PID=%08x\n\n",pid_t);

        if (usbdata->productid==pid_t && usbdata->vendorid==vid_t) {
            if (usbdata->locationID==0x0)
            {
                printf("\n\nusbdata->locationID=%08x\n\n",location_t);
                usbdata->r_locationID=location_t;
                if (usbdata->semaphore) {
                    dispatch_semaphore_signal(usbdata->semaphore);
                }
                break;
            }else if(usbdata->locationID==location_t)
            {
                printf("\n\nusbdata->locationID=%08x",location_t);
                usbdata->r_locationID=location_t;
                if (usbdata->semaphore) {
                    dispatch_semaphore_signal(usbdata->semaphore);
                }
                break;
            }
        }
    }
}
@interface NotificationScanUSB : NSObject{
    MyUSBData *usbdata;
}

-(void)OnEngineNotification:(NSNotification *)nf;
-(void)AddNotificationToCenter:(MyUSBData*)object;
@end
@implementation NotificationScanUSB
-(void)OnEngineNotification:(NSNotification *)nf
{
    dispatch_semaphore_signal(usbdata->semaphore);
}
#define kNotificationOnTestCancel       @"On_TestCancel"

-(void)AddNotificationToCenter:(MyUSBData*)object
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        usbdata=object;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnEngineNotification:) name:kNotificationOnTestCancel object:nil];
        CFRunLoopRun();
    });
}
-(void)RemoveNotificationToCenter
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotificationOnTestCancel object:nil];
    CFRunLoopStop(CFRunLoopGetCurrent());
}
@end
void NotificationCenterCallback(
                                CFNotificationCenterRef center,
                                void *observer,
                                CFStringRef name,
                                const void *object,
                                CFDictionaryRef userInfo)
{
    
}
unsigned int CheckUSBHID(unsigned short vendor_id, unsigned short product_id,unsigned int locationid,int itimeout)
{
    CFMutableDictionaryRef 	matchingDict;
    CFNumberRef				numberRef;
    MyUSBData *usbdata=new MyUSBData();
    usbdata->locationID=locationid;
    usbdata->productid=product_id;
    usbdata->vendorid=vendor_id;
    matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    if (matchingDict == NULL) {
        fprintf(stderr, "IOServiceMatching returned NULL.\n");
        return -1;
    }
    /*
     set search pid and vid
     */
    // Create a CFNumber for the idVendor and set the value in the dictionary
    //    numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &vendor_id);
    //    CFDictionarySetValue(matchingDict,
    //                         CFSTR(kUSBVendorID),
    //                         numberRef);
    //    CFRelease(numberRef);
    //
    //    // Create a CFNumber for the idProduct and set the value in the dictionary
    //    numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &product_id);
    //    CFDictionarySetValue(matchingDict,
    //                         CFSTR(kUSBProductID),
    //                         numberRef);
    //    CFRelease(numberRef);
    numberRef = NULL;
    
    usbdata->semaphore=dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        kern_return_t			kr;
        CFRunLoopSourceRef		runLoopSource;
        usbdata->NotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
        runLoopSource = IONotificationPortGetRunLoopSource(usbdata->NotifyPort);
        
        usbdata->RunLoop = CFRunLoopGetCurrent();
        CFRunLoopAddSource(usbdata->RunLoop, runLoopSource, kCFRunLoopCommonModes);
        
        kr = IOServiceAddMatchingNotification(usbdata->NotifyPort,					// notifyPort
                                              kIOFirstMatchNotification,	// notificationType
                                              matchingDict,					// matching
                                              ScanUSB,					// callback
                                              usbdata,							// refCon
                                              &(usbdata->AddedIter)					// notification
                                              );
        ScanUSB(usbdata,usbdata->AddedIter);
        CFRunLoopRun();
    });
    NotificationScanUSB *notificationScanUSB=[[NotificationScanUSB alloc] init];
    [notificationScanUSB AddNotificationToCenter:usbdata];
    dispatch_time_t t=dispatch_time(DISPATCH_TIME_NOW, (UInt64)itimeout*1000L*1000L);
    
    dispatch_semaphore_wait(usbdata->semaphore, t);
    [notificationScanUSB RemoveNotificationToCenter];
    [notificationScanUSB release];
    CFRunLoopStop(usbdata->RunLoop);
    dispatch_release(usbdata->semaphore);
    if (usbdata->AddedIter) {
        IOObjectRelease(usbdata->AddedIter);
        usbdata->AddedIter = IO_OBJECT_NULL;
    }
    if (usbdata->NotifyPort) {
        if (auto loop_source = IONotificationPortGetRunLoopSource(usbdata->NotifyPort)) {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), loop_source, kCFRunLoopDefaultMode);
        }
        IONotificationPortDestroy(usbdata->NotifyPort);
        usbdata->NotifyPort = nil;
    }
    if (usbdata->r_locationID) {
        UInt32 location=usbdata->r_locationID;
        delete usbdata;
        return location;
    }
    return 0;
}
NSMutableArray* GetUSBDeviceListByDeviceName(NSString *devName)
{
    NSMutableArray *List = [[NSMutableArray alloc] init];
    Context context;
    context.bScanAlldevice = 1;
    context.arrDevList = [NSMutableArray array];
    ScanDevice(0, 0, &context);
    
    for (NSDictionary * dic in context.arrDevList)
    {
        NSLog(@"Location ID: %@",[dic valueForKey:kLocationID]);
        NSLog(@"Device Name: %@",[dic valueForKey:kDeviceName]);
        [List addObject:[NSString stringWithFormat:@"device name is %@ and location id is %@",[dic valueForKey:kDeviceName],[dic valueForKey:kLocationID]]];
//        if([[dic valueForKey:kDeviceName] isEqual: devName])
//        {
//            [List addObject:[dic valueForKey:kLocationID]];
//        }
    }
    printf("Couldn't find the speccial device!\r\n");
    
    return List;
}

