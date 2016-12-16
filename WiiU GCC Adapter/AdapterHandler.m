//
//  Functions.h
//  wiiu-gcc-adapter-bin
//
//  Copyright © 2016 JurMax. All rights reserved.
//
//  USB-handling (usage of libusb) is based on work by Mitch Dzugan and TODO - many thanks to them!
//

#import "AdapterHandler.h"


const SInt32 VENDOR_ID = 0x057e;
const SInt32 PRODUCT_ID = 0x0337;


Functions *functions;
struct libusb_transfer *transfer_in = NULL; // IN-comiddleg transfers (IN to host PC from USB-device)
unsigned char in_buffer[38];

NSArray *controllers;
bool isControllerInserted[4] = { false, false, false, false };


@implementation GCController

@synthesize VHID;
@synthesize virtualDevice;


- (GCController *) setup:(int) port {
    [WJoyDevice prepare];
    VHID = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeJoystick pointerCount:3 buttonCount:12 isRelative:NO];
    
    NSDictionary *properties = @{
            WJoyDeviceProductStringKey: ([NSString stringWithFormat: @"WiiU GCC Port %@", @[@"1", @"2", @"3", @"4"] [port]]),
            WJoyDeviceSerialNumberStringKey: ([NSString stringWithFormat:@"1%@", @[@"1", @"2", @"3", @"4"] [port]])  };
    
    virtualDevice = [[WJoyDevice alloc] initWithHIDDescriptor:[VHID descriptor] properties:properties];
    [VHID setDelegate:self];
    
    return self;
}


- (void) remove {
    [VHID reset];
    
    VHID = nil;
    virtualDevice = nil;
}


- (void) VHIDDevice:(VHIDDevice *) device stateChanged:(NSData *) state {
    [virtualDevice updateHIDState:state];
}


@end



@implementation GccManager

@synthesize dev_handle;
@synthesize context;


- (int) setup:(Functions * ) func {
    functions = func;
    
    dev_handle = nil;
    context = nil;
    
    libusb_device **devs;
    ssize_t cnt;
    
    libusb_init(&context);
    libusb_set_debug(context, 3);
    cnt = libusb_get_device_list(context, &devs);
    dev_handle = libusb_open_device_with_vid_pid(context, VENDOR_ID, PRODUCT_ID);
    libusb_free_device_list(devs, 1);
    
    if (dev_handle == NULL) {
        return 0;
    }
    
    if (libusb_kernel_driver_active(dev_handle, 0) == 1) {
        libusb_detach_kernel_driver(dev_handle, 0);
    }
    
    libusb_claim_interface(dev_handle, 0);
    
    int actual;
    unsigned char data[40];
    data[0] = 0x13;
    
    libusb_bulk_transfer(dev_handle, (2 | LIBUSB_ENDPOINT_OUT), data, 1, &actual, 0);

    [self removeControllers];
    controllers = @[[[GCController alloc] init],
                    [[GCController alloc] init],
                    [[GCController alloc] init],
                    [[GCController alloc] init]];
    
    transfer_in = libusb_alloc_transfer(0);
    libusb_fill_bulk_transfer(transfer_in, dev_handle, (1 | LIBUSB_ENDPOINT_IN), in_buffer, 37, cbin, NULL, 0);
    libusb_submit_transfer(transfer_in);
    
    return 1;
}


- (void) update {
    libusb_handle_events_completed(context, NULL);
}


- (bool) isControllerInserted:(int) i {
    return isControllerInserted[i];
}


- (void) reset {
    [self removeControllers];
    bool isIntialised = functions.isDriverInitialized;
    if (isIntialised) {
        libusb_cancel_transfer(transfer_in);
        libusb_release_interface(dev_handle, 0);
    }
    functions.isDriverInitialized = false;
}


- (void) removeControllers {
    for (int i = 0; i < 4; i++) {
        if (controllers[i] != NULL)
            [controllers[i] remove];
        isControllerInserted[i] = false;
    }
    
    [functions validateCalibrateButtons];
}


@end



void cbin(struct libusb_transfer* transfer) {
    unsigned char *p = in_buffer + 1;
    
    unsigned char stickXRaw, stickYRaw;
    NSPoint point = NSZeroPoint;
    
    if (transfer -> status > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [functions addStringtoLog:@"- Something went wrong, the driver will close. -\n"];
            [functions stopDriver];
            //TODO
            [functions.gccManager reset];
        });
    };
    
    for (int i = 0; i < 4; i++) {
        bool controllerInserted = p[0] > 4;
        if (controllerInserted) {
            if (!isControllerInserted[i]) {
                isControllerInserted[i] = true;
                [(GCController *) (controllers[i]) setup:i];

                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *string = [NSString stringWithFormat: @"  Controller detected in port %i.\n", i + 1];
                    [functions addStringtoLog: string];
                    [functions validateCalibrateButtons];
                });
            }
            
            VHIDDevice *VHID = [controllers[i] VHID];
            [VHID setButton:0  pressed:(p[1] & (1 << 0)) != 0];
            [VHID setButton:1  pressed:(p[1] & (1 << 1)) != 0];
            [VHID setButton:2  pressed:(p[1] & (1 << 2)) != 0];
            [VHID setButton:3  pressed:(p[1] & (1 << 3)) != 0];
            [VHID setButton:4  pressed:(p[1] & (1 << 4)) != 0];
            [VHID setButton:5  pressed:(p[1] & (1 << 5)) != 0];
            [VHID setButton:6  pressed:(p[1] & (1 << 6)) != 0];
            [VHID setButton:7  pressed:(p[1] & (1 << 7)) != 0];
            [VHID setButton:8  pressed:(p[2] & (1 << 0)) != 0];
            [VHID setButton:9  pressed:(p[2] & (1 << 1)) != 0];
            [VHID setButton:10 pressed:(p[2] & (1 << 2)) != 0];
            [VHID setButton:11 pressed:(p[2] & (1 << 3)) != 0];
            
            
            stickXRaw = p[3];  // main stick x
            stickYRaw = p[4];  // main stick y
            handleCalibration(i, 1, stickXRaw, stickYRaw);
            
            if (!disableDeadzones[i]) {
                if (stickXRaw <= stick_middle_x[i] + stick_deadzone_x[i] && stickXRaw >= stick_middle_x[i] - stick_deadzone_x[i])
                    stickXRaw = stick_middle_x[i];
                if (stickYRaw <= stick_middle_y[i] + stick_deadzone_y[i] && stickYRaw >= stick_middle_y[i] - stick_deadzone_y[i])
                    stickYRaw = stick_middle_y[i];
            }
            
            point.x = (float) (stickXRaw - stick_middle_x[i]) / (float) (stick_max_x[i]);
            point.y = (float) (stickYRaw - stick_middle_y[i]) / (float) (stick_max_y[i]);
            if (disableSticks[i]) point.x = 0.0;
            if (disableSticks[i]) point.y = 0.0;
            [VHID setPointer:0 position:point];
            
            
            
            stickXRaw = p[7];  // l-analog (25 to 242)
            stickYRaw = p[5];  // c-stick x
            handleCalibration(i, 2, stickXRaw, stickYRaw);
            
            if (!disableDeadzones[i]) {
                if (stickXRaw <= l_middle[i] + l_deadzone[i])
                    stickXRaw = l_middle[i];
                if (stickYRaw <= c_stick_middle_x[i] + c_stick_deadzone_x[i] && stickYRaw >= c_stick_middle_x[i] - c_stick_deadzone_x[i])
                    stickYRaw = c_stick_middle_x[i];
            }
            
            point.x = (float) (stickXRaw - l_middle[i]) / (float) (l_max[i]);
            point.y = -(float) (stickYRaw - c_stick_middle_x[i]) / (float) (stick_max_x[i]);
            if (disable_l_analog[i]) point.x = 0;
            if (disableSticks[i]) point.y = 0;
            [VHID setPointer:1 position:point];
            
            
            stickXRaw = p[6];  // c-stick y
            stickYRaw = p[8];  // r-analog
            handleCalibration(i, 3, stickXRaw, stickYRaw);
            
            if (!disableDeadzones[i]) {
                if (stickXRaw <= c_stick_middle_y[i] + c_stick_deadzone_y[i] && stickYRaw >= c_stick_middle_y[i] - c_stick_deadzone_y[i])
                    stickXRaw = c_stick_middle_y[i];
                if (stickYRaw <= r_middle[i] + r_deadzone[i])
                    stickYRaw = r_middle[i];
            }
            
            point.x = (float) (stickXRaw - c_stick_middle_y[i]) / (float) stick_max_y[i];
            point.y = (float) (stickYRaw - r_middle[i]) / (float) r_max[i];
            if (disableSticks[i]) point.x = 0;
            if (disable_r_analog[i])  point.y = 0;
            [VHID setPointer:2 position:point];
            
            
        } else {  /* controller is not inserted */
            VHIDDevice *VHID = [controllers[i] VHID];
            point.x = 0;
            point.y = 0;
            [VHID setPointer:0 position:point];
            [VHID setPointer:1 position:point];
            [VHID setPointer:2 position:point];
            
            if (isControllerInserted[i]) {
                isControllerInserted[i] = false;
                [(GCController *) (controllers[i]) remove];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *string = [NSString stringWithFormat:@"  Controller removed from port %i.\n", i + 1];
                    [functions addStringtoLog: string];
                    [functions validateCalibrateButtons];
                    
                    OptionsViewController *optionview = functions.optionsViewController;
                    bool flags =  optionview != nil && optionview.isViewLoaded && optionview.view.window;
                    if (flags && optionview.currentPort == i) {
                        [functions.optionsViewController dismissViewController: functions.optionsViewController];
                    }
                });
            }
            
        }
        
        p += 9;
    }
    
    libusb_submit_transfer(transfer_in);
}


void handleCalibration(int port, int level, int stickX, int stickY) {
    if (calibrationState[port] == 1) {
        stick_max_x[port] = 0;
        stick_max_y[port] = 0;
        c_stick_max_x[port] = 0;
        c_stick_max_y[port] = 0;
        l_max[port] = 0;
        r_max[port] = 0;
    }
    else if (calibrationState[port] == 2) {  /* all middles */
        if (level == 1) {
            stick_middle_x[port] = stickX;
            stick_middle_y[port] = stickY;
        } else if (level == 2) {
            l_middle[port] = stickX;
            c_stick_middle_x[port] = stickY;
        } else if (level == 3) {
            c_stick_middle_y[port] = stickX;
            r_middle[port] = stickY;
            calibrationState[port] = -1;
        }
    }
    else if (calibrationState[port] == -1) {  /* main stick highs */
        if (level == 1) {
            int diffX = abs(stickX - stick_middle_x[port]);
            if (diffX > stick_max_x[port]) {
                stick_max_x[port] = diffX;
            }
            int diffY = abs(stickY - stick_middle_y[port]);
            if (diffY > stick_max_y[port]) {
                stick_max_y[port] = diffY;
            }
        }
    }
    else if (calibrationState[port] == 3) {  /* c stick highs */
        if (level == 2) {
            int diffX = abs(stickY - c_stick_middle_x[port]);
            if (diffX > c_stick_max_x[port]) {
                c_stick_max_x[port] = diffX;
            }
        } else if (level == 3) {
            int diffY = abs(stickX - c_stick_middle_y[port]);
            if (diffY > c_stick_max_y[port]) {
                c_stick_max_y[port] = diffY;
            }
        }
    }
    else if (calibrationState[port] == 4) {  /* l and r highs */
        if (level == 2) {
            if (stickX > l_max[port]) {
                l_max[port] = stickX;
            }
        } else if (level == 3) {
            if (stickY > r_max[port]) {
                r_max[port] = stickY;
            }
        }
    }
    
    if (calibrationState[port] == 5) {
        calibrationState[port] = 0;
    }
}

