//
//  AdapterHandler.h
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <WirtualJoy/WJoyDevice.h>
#import <VHID/VHIDDevice.h>
#import "libusb.h"
#import "Functions.h"
#import "ViewController.h"

#ifndef AdapterHandler_h
#define AdapterHandler_h

@class Functions;

@interface Gcc : NSObject <VHIDDeviceDelegate>
@property (strong, nonatomic) VHIDDevice *VHID;
@property (strong, nonatomic) WJoyDevice *virtualDevice;
@end

@interface GccManager : NSObject
@property (nonatomic) libusb_device_handle *dev_handle;
@property (nonatomic) libusb_context *ctx;
@property (nonatomic) int r;

- (int) setup;
- (void) reset;
- (void) update;
- (void) loadControllerCalibrations;
- (void) saveControllerCalibrations;
@end



#endif /* AdapterHandler_h */
