//
//  AdapterHandler.h
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WirtualJoy/WJoyDevice.h>
#import <VHID/VHIDDevice.h>

#import "libusb.h"
#import "Functions.h"
#import "OptionsViewController.h"
#import "Calibration.h"


@class Functions;
@class OptionsViewController;


@interface GCController : NSObject <VHIDDeviceDelegate>

@property (strong, nonatomic) VHIDDevice *VHID;
@property (strong, nonatomic) WJoyDevice *virtualDevice;

- (GCController *) setup:(int) port;
- (void) remove;
- (void) VHIDDevice:(VHIDDevice *) device stateChanged:(NSData *) state;

@end


@interface GccManager : NSObject

@property (nonatomic) libusb_device_handle *dev_handle;
@property (nonatomic) libusb_context *context;

- (int) setup:(Functions * ) func;
- (void) update;
- (bool) isControllerInserted:(int) i;
- (void) reset;
- (void) removeControllers;

@end


void cbin(struct libusb_transfer* transfer);
void handleCalibration(int port, int level, int stickX, int stickY);


