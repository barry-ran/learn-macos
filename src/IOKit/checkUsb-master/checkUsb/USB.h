//
//  USB.h
//  Global
//
//  Created by Ryan on 13-2-20.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#ifndef Global_USB_h
#define Global_USB_h
UInt32 GetUsbLocation(long vid,long pid);
int CheckUsbDevice(long vid,long pid);
long HexToLong(const char *stringValue);
const char *ToHex(uint16_t tmpid);
int CheckUsbDeviceInPort(long vid,long pid,int port);
char* GetUsbSerialNumber(long vid,long pid);
char *GetUsbVersion(long vid,long pid);
unsigned int CheckUSBHID(unsigned short vendor_id, unsigned short product_id,unsigned int locationid,int itimeout);
void ScanUSB(void *refCon, io_iterator_t iterator);
NSMutableArray* GetUSBDeviceListByDeviceName(NSString *devName);

#endif
