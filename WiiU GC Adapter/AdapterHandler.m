//
//  main.m
//  wiiu-gcc-adapter
//
//  A lot of this is based on work by Mitch Dzugan - many thanks to him!

#import "AdapterHandler.h"


const float DEADZONE = 20;
//const float MAX_VALUE = 10;

struct libusb_transfer *transfer_in = NULL; // IN-comiddleg transfers (IN to host PC from USB-device)
unsigned char in_buffer[38];

NSArray *controllers;
bool isControllerInserted[4] = { FALSE, FALSE, FALSE, FALSE };
int isBeingCalibrated[4] = { 0, 0, 0, 0 };

Functions *functions;

bool disable_l_analog[4];
bool disable_r_analog[4];
bool disableDeadzones[4];
bool disableSticks[4];
int stick_max_x[4], stick_middle_x[4], stick_max_y[4], stick_middle_y[4];
int c_stick_max_x[4], c_stick_middle_x[4], c_stick_max_y[4], c_stick_middle_y[4];
int r_max[4], r_middle[4], l_max[4], l_middle[4];
int stick_deadzone_x[4], stick_deadzone_y[4], c_stick_deadzone_x[4], c_stick_deadzone_y[4], l_deadzone[4], r_deadzone[4];


@implementation Gcc
@synthesize VHID;
@synthesize virtualDevice;

- (Gcc *)setup:(int)ind {
    [WJoyDevice prepare];
    VHID = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeJoystick pointerCount:3 buttonCount:12 isRelative:NO];
    
    NSDictionary *properties = @{ WJoyDeviceProductStringKey : ( [NSString stringWithFormat: @"WiiU GCC Port %@", @[@"1", @"2", @"3", @"4"] [ind]] ),
                                  WJoyDeviceSerialNumberStringKey : ( [NSString stringWithFormat:@"1%@", @[@"1", @"2", @"3", @"4"] [ind]] ) };
    
    virtualDevice = [[WJoyDevice alloc] initWithHIDDescriptor:[VHID descriptor] properties:properties];
    [VHID setDelegate:self];
    return self;
}

- (void) remove {
    VHID = nil;
    virtualDevice = nil;
}

- (void)VHIDDevice:(VHIDDevice *)device stateChanged:(NSData *)state {
    [virtualDevice updateHIDState:state];
}

/** really bad handled calibration, as I have no knowledge of how this is supposed to be done :P */
- (void) handleCalibration: (int) port : (int) i : (int)stickX : (int)stickY{
    if (isBeingCalibrated[port] == 1) {
        stick_max_x[port] = 0.0;
        stick_max_y[port] = 0.0;
        c_stick_max_x[port] = 0.0;
        c_stick_max_y[port] = 0.0;
        l_max[port] = 0.0;
        r_max[port] = 0.0;
    } else if (isBeingCalibrated[port] == 2) {  /* all middles */
        if (i == 1) {
            stick_middle_x[port] = stickX;
            stick_middle_y[port] = stickY;
        } else if (i == 2) {
            l_middle[port] = stickX;
            c_stick_middle_x[port] = stickY;
        } else if (i == 3) {
            c_stick_middle_y[port] = stickX;
            r_middle[port] = stickY;
            isBeingCalibrated[port] = -1;
        }
    } else if (isBeingCalibrated[port] == -1) {  /* main stick highs */
        if (i == 1) {
            int diffX = abs(stickX - stick_middle_x[port]);
            printf("ding: %i %i %i %i\n", stickX, diffX, stick_max_x[port], stick_middle_x[port]);
            if (diffX > stick_max_x[port]) {
                stick_max_x[port] = diffX;
            }
            int diffY = abs(stickY - stick_middle_y[port]);
            if (diffY > stick_max_y[port]) {
                stick_max_y[port] = diffY;
            }
        }
    } else if (isBeingCalibrated[port] == 3) {  /* c stick highs */
        if (i == 2) {
            int diffX = abs(stickY - c_stick_middle_x[port]);
            if (diffX > c_stick_max_x[port]) {
                c_stick_max_x[port] = diffX;
            }
        } else if (i == 3) {
            int diffY = abs(stickX - c_stick_middle_y[port]);
            if (diffY > c_stick_max_y[port]) {
                c_stick_max_y[port] = diffY;
            }
        }
    } else if (isBeingCalibrated[port] == 4) {  /* l and r highs */
        if (i == 2) {
            if (stickX > l_max[port])
                l_max[port] = stickX;
        } else if (i == 3) {
            if (stickY > r_max[port])
                r_max[port] = stickY;
        }
    }
    if (isBeingCalibrated[port] == 5) {
        isBeingCalibrated[port] = 0;
    }
}

@end


void cbin(struct libusb_transfer* transfer) {
    unsigned char * p = in_buffer+1;
    unsigned char stickXRaw, stickYRaw;
    float stickX, stickY;
    NSPoint point = NSZeroPoint;
    
    if (transfer -> status > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [functions addStringtoLog:@"- Something went wrong, the driver will close. -\n"];
            [functions stopDriver];
            functions.isInitialized = FALSE;
        });
    };
    
    
    for (int i = 0; i < 4; i++) {
        if (p[0] > 4) { /* Is controller inserted*/
            if (!isControllerInserted[i]) {
                isControllerInserted[i] = TRUE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *string = [NSString stringWithFormat: @"  Controller detected in port %i.\n", i + 1];
                    [functions addStringtoLog: string];
                    [functions validateCalibrateButtons];
                });
                [(Gcc *) (controllers[i]) setup:i];
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
            
            
            bool f = !disableDeadzones[i];
            
            stickXRaw = p[3]; // main stick x
            stickYRaw = p[4]; // main stick y
            
            [(Gcc *) (controllers[i]) handleCalibration: i : 1 : stickXRaw : stickYRaw];
            if (stickXRaw <= stick_middle_x[i] + stick_deadzone_x[i] && stickXRaw >= stick_middle_x[i] - stick_deadzone_x[i] && f)
                stickXRaw = stick_middle_x[i];
            if (stickYRaw <= stick_middle_y[i] + stick_deadzone_y[i] && stickYRaw >= stick_middle_y[i] - stick_deadzone_y[i] && f)
                stickYRaw = stick_middle_y[i];
            stickX = (float) (stickXRaw - stick_middle_x[i]) / (float) stick_max_x[i];
            stickY = (float) (stickYRaw - stick_middle_y[i]) / (float) stick_max_y[i];
            point.x = stickX;
            point.y = stickY;
            if (disableSticks[i]) {
                stickX = 0.0;
                stickY = 0.0;
            }
            [VHID setPointer:0 position:point];
            
            
            stickXRaw = p[7]; // l-analog (25 to 242)
            stickYRaw = p[5]; // c-stick x
            
            [(Gcc *) (controllers[i]) handleCalibration: i : 2 : stickXRaw : stickYRaw];
            if (stickXRaw <= l_middle[i] + l_deadzone[i] && f)
                stickXRaw = l_middle[i];
            if (stickYRaw <= c_stick_middle_x[i] + c_stick_deadzone_x[i] && stickYRaw >= c_stick_middle_x[i] - c_stick_deadzone_x[i] && f)
                stickYRaw = c_stick_middle_x[i];
            stickX = (float) (stickXRaw - l_middle[i]) / (float) l_max[i];
            stickY = -(float) (stickYRaw - c_stick_middle_x[i]) / (float) stick_max_x[i];
            if (disable_l_analog[i])
                stickX = 0.0;
            if (disableSticks[i])
                stickY = 0.0;
            point.x = stickX;
            point.y = stickY;
            [VHID setPointer:1 position:point];
            
            
            stickXRaw = p[6];  // c-stick y
            stickYRaw = p[8];  // r-analog
            
            [(Gcc *) (controllers[i]) handleCalibration: i : 3 : stickXRaw : stickYRaw];
            if (stickXRaw <= c_stick_middle_y[i] + c_stick_deadzone_y[i] && stickYRaw >= c_stick_middle_y[i] - c_stick_deadzone_y[i] && f)
                stickXRaw = c_stick_middle_y[i];
            if (stickYRaw <= r_middle[i] + r_deadzone[i] && f)
                stickYRaw = r_middle[i];
            stickX = (float) (stickXRaw - c_stick_middle_y[i]) / (float) stick_max_y[i];
            stickY = (float) (stickYRaw - r_middle[i]) / (float) r_max[i];
            if (disableSticks[i])
                stickX = 0.0;
            if (disable_r_analog[i])
                stickY = 0.0;
            point.x = stickX;
            point.y = stickY;
            [VHID setPointer:2 position:point];
            
        } else {  /* controller is not inserted */
            
            VHIDDevice *VHID = [controllers[i] VHID];
            point.x = 0;
            point.y = 0;
            [VHID setPointer:0 position:point];
            [VHID setPointer:1 position:point];
            [VHID setPointer:2 position:point];
            
            if (isControllerInserted[i]) {
                isControllerInserted[i] = FALSE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *string = [NSString stringWithFormat:@"  Controller removed from port %i.\n", i + 1];
                    [functions addStringtoLog: string];
                    [functions validateCalibrateButtons];
                    bool flags = functions.optionsViewController != nil && functions.optionsViewController.isViewLoaded && functions.optionsViewController.view.window;
                    if (flags && functions.optionsViewController.currentPort == i)
                        [functions.optionsViewController dismissViewController: functions.optionsViewController];
                });
                [(Gcc*) (controllers[i]) remove];
            }
            
        }
        p += 9;
    }
    
    libusb_submit_transfer(transfer_in);
}




@implementation GccManager
@synthesize dev_handle;

@synthesize r;
@synthesize ctx;

- (int) setup: (Functions * ) fnctns {
    functions = fnctns;
    
    SInt32 idVendor = 0x057e;
    SInt32 idProduct = 0x0337;
    
    r = 0;
    ctx = nil;

    libusb_device **devs;
    ssize_t cnt;
    r = libusb_init(&ctx);
    libusb_set_debug(ctx, 3);
    cnt = libusb_get_device_list(ctx, &devs);
    dev_handle = libusb_open_device_with_vid_pid(ctx, idVendor, idProduct);
    libusb_free_device_list(devs, 1);
    if (dev_handle == NULL) {
        return 0;
    }
    
    if (libusb_kernel_driver_active(dev_handle, 0) == 1) {
        libusb_detach_kernel_driver(dev_handle, 0);
    }
    
    r = libusb_claim_interface(dev_handle, 0);
    int actual;
    unsigned char data[40];
    data[0] = 0x13;
    libusb_bulk_transfer(dev_handle, (2 | LIBUSB_ENDPOINT_OUT), data, 1, &actual, 0);

    [self removeControllers];
    controllers = @[[[Gcc alloc] init], [[Gcc alloc] init], [[Gcc alloc] init], [[Gcc alloc] init]];
    
    transfer_in  = libusb_alloc_transfer(0);
    libusb_fill_bulk_transfer(transfer_in, dev_handle, (1 | LIBUSB_ENDPOINT_IN), in_buffer, 37, cbin, NULL, 0);
    r = libusb_submit_transfer(transfer_in);
    
    return 1;
}


- (void) reset {
    [self removeControllers];
    bool isIntialised = ((ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController).functions.isInitialized;
    if (isIntialised) {
        libusb_cancel_transfer(transfer_in);
        libusb_release_interface(dev_handle, 0);
    }
}

- (void) removeControllers {
    for (int i; i < 4; i++) {
        if (controllers[i] != NULL)
            [controllers[i] remove];
        isControllerInserted[i] = FALSE;
    }
}

- (void) update {
    r = libusb_handle_events_completed(ctx, NULL);
}

- (bool) isControllerInserted: (int) i {
    return isControllerInserted[i];
}


- (void) loadControllerCalibrations {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *stickString;
    if (standardUserDefaults) {
        stickString = [standardUserDefaults objectForKey:@"stick"];
        short int count;
        
        if (stickString != NULL) {
            stickString = [standardUserDefaults objectForKey:@"stick"];
            NSArray *listItems = [stickString componentsSeparatedByString:@"."];
            count = 0;
            for (id value in listItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) stick_max_x[0] = i;  if(count==1) stick_max_x[1] = i;
                if(count==2) stick_max_x[2] = i;  if(count==3) stick_max_x[3] = i;
                if(count==4) stick_middle_x[0] = i;  if(count==5) stick_middle_x[1] = i;
                if(count==6) stick_middle_x[2] = i;  if(count==7) stick_middle_x[3] = i;
                if(count==8) stick_max_y[0] = i;  if(count==9) stick_max_y[1] = i;
                if(count==10) stick_max_y[2] = i;  if(count==11) stick_max_y[3] = i;
                if(count==12) stick_middle_y[0] = i;  if(count==13) stick_middle_y[1] = i;
                if(count==14) stick_middle_y[2] = i;  if(count==15) stick_middle_y[3] = i;
                count++;
            }
            
            stickString = [standardUserDefaults objectForKey:@"c_stick"];
            listItems = [stickString componentsSeparatedByString:@"."];
            count = 0;
            for (id value in listItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) c_stick_max_x[0] = i;  if(count==1) c_stick_max_x[1] = i;
                if(count==2) c_stick_max_x[2] = i;  if(count==3) c_stick_max_x[3] = i;
                if(count==4) c_stick_middle_x[0] = i;  if(count==5) c_stick_middle_x[1] = i;
                if(count==6) c_stick_middle_x[2] = i;  if(count==7) c_stick_middle_x[3] = i;
                if(count==8) c_stick_max_y[0] = i;  if(count==9) c_stick_max_y[1] = i;
                if(count==10) c_stick_max_y[2] = i;  if(count==11) c_stick_max_y[3] = i;
                if(count==12) c_stick_middle_y[0] = i;  if(count==13) c_stick_middle_y[1] = i;
                if(count==14) c_stick_middle_y[2] = i;  if(count==15) c_stick_middle_y[3] = i;
                count++;
            }
            
            count = 0;
            stickString = [standardUserDefaults objectForKey:@"l_and_r"];
            listItems = [stickString componentsSeparatedByString:@"."];
            for (id value in listItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) r_max[0] = i;  if(count==1) r_max[1] = i;
                if(count==2) r_max[2] = i;  if(count==3) r_max[3] = i;
                if(count==4) r_middle[0] = i;  if(count==5) r_middle[1] = i;
                if(count==6) r_middle[2] = i;  if(count==7) r_middle[3] = i;
                if(count==8) l_max[0] = i;  if(count==9) l_max[1] = i;
                if(count==10) l_max[2] = i;  if(count==11) l_max[3] = i;
                if(count==12) l_middle[0] = i;  if(count==13) l_middle[1] = i;
                if(count==14) l_middle[2] = i;  if(count==15) l_middle[3] = i;
                count++;
            }
            
            count = 0;
            stickString = [standardUserDefaults objectForKey:@"deadzones"];
            listItems = [stickString componentsSeparatedByString:@"."];
            for (id value in listItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) stick_deadzone_x[0] = i;  if(count==1) stick_deadzone_x[1] = i;
                if(count==2) stick_deadzone_x[2] = i;  if(count==3) stick_deadzone_x[3] = i;
                if(count==4) stick_deadzone_y[0] = i;  if(count==5) stick_deadzone_y[1] = i;
                if(count==6) stick_deadzone_y[2] = i;  if(count==7) stick_deadzone_y[3] = i;
                
                if(count==8) c_stick_deadzone_x[0] = i;  if(count==9) c_stick_deadzone_x[1] = i;
                if(count==10) c_stick_deadzone_x[2] = i;  if(count==11) c_stick_deadzone_x[3] = i;
                if(count==12) c_stick_deadzone_y[0] = i;  if(count==13) c_stick_deadzone_y[1] = i;
                if(count==14) c_stick_deadzone_y[2] = i;  if(count==15) c_stick_deadzone_y[3] = i;

                if(count==16) l_deadzone[0] = i;  if(count==17) l_deadzone[1] = i;
                if(count==18) l_deadzone[2] = i;  if(count==19) l_deadzone[3] = i;
                if(count==20) r_deadzone[0] = i;  if(count==21) r_deadzone[1] = i;
                if(count==22) r_deadzone[2] = i;  if(count==23) r_deadzone[3] = i;
                
                if(count==24) disableDeadzones[0] = i;  if(count==25) disableDeadzones[1] = i;
                if(count==26) disableDeadzones[2] = i;  if(count==27) disableDeadzones[3] = i;
                if(count==28) disable_l_analog[0] = i;  if(count==29) disable_l_analog[1] = i;
                if(count==30) disable_l_analog[2] = i;  if(count==31) disable_l_analog[3] = i;
                if(count==32) disable_r_analog[0] = i;  if(count==33) disable_r_analog[1] = i;
                if(count==34) disable_r_analog[2] = i;  if(count==35) disable_r_analog[3] = i;
                if(count==36) disableSticks[0] = i;  if(count==37) disableSticks[1] = i;
                if(count==38) disableSticks[2] = i;  if(count==39) disableSticks[3] = i;
                count++;
            }
        } else {
            [((ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController).functions addStringtoLog:@"  No controller calibrations found, using defaults."];
            [self loadDefaultCalibrations];
            [self saveControllerCalibrations];
        }
    }
}


- (void) saveControllerCalibrations {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSString *values1 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_max_x[0], stick_max_x[1], stick_max_x[2], stick_max_x[3]];
        NSString *values2 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_middle_x[0], stick_middle_x[1], stick_middle_x[2], stick_middle_x[3]];
        NSString *values3 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_max_y[0], stick_max_y[1], stick_max_y[2], stick_max_y[3]];
        NSString *values4 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_middle_y[0], stick_middle_y[1], stick_middle_y[2], stick_middle_y[3]];
        NSString *valuescombined = [NSString stringWithFormat:@"%@.%@.%@.%@", values1, values2, values3, values4];
        [standardUserDefaults setObject:valuescombined forKey:@"stick"];
        
        values1 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_max_x[0], c_stick_max_x[1], c_stick_max_x[2], c_stick_max_x[3]];
        values2 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_middle_x[0], c_stick_middle_x[1], c_stick_middle_x[2], c_stick_middle_x[3]];
        values3 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_max_y[0], c_stick_max_y[1], c_stick_max_y[2], c_stick_max_y[3]];
        values4 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_middle_y[0], c_stick_middle_y[1], c_stick_middle_y[2], c_stick_middle_y[3]];
        valuescombined = [NSString stringWithFormat:@"%@.%@.%@.%@", values1, values2, values3, values4];
        [standardUserDefaults setObject:valuescombined forKey:@"c_stick"];
        
        values1 = [NSString stringWithFormat:@"%i.%i.%i.%i", r_max[0], r_max[1], r_max[2], r_max[3]];
        values2 = [NSString stringWithFormat:@"%i.%i.%i.%i", r_middle[0], r_middle[1], r_middle[2], r_middle[3]];
        values3 = [NSString stringWithFormat:@"%i.%i.%i.%i", l_max[0], l_max[1], l_max[2], l_max[3]];
        values4 = [NSString stringWithFormat:@"%i.%i.%i.%i", l_middle[0], l_middle[1], l_middle[2], l_middle[3]];
        valuescombined = [NSString stringWithFormat:@"%@.%@.%@.%@", values1, values2, values3, values4];
        [standardUserDefaults setObject:valuescombined forKey:@"l_and_r"];
        
        values1 = [NSString stringWithFormat:@"%i.%i.%i.%i.%i.%i.%i.%i", stick_deadzone_x[0], stick_deadzone_x[1], stick_deadzone_x[2], stick_deadzone_x[3],
                stick_deadzone_y[0], stick_deadzone_y[1], stick_deadzone_y[2], stick_deadzone_y[3]];
        values2 = [NSString stringWithFormat:@"%i.%i.%i.%i.%i.%i.%i.%i", c_stick_deadzone_x[0], c_stick_deadzone_x[1], c_stick_deadzone_x[2], c_stick_deadzone_x[3], c_stick_deadzone_y[0], c_stick_deadzone_y[1], c_stick_deadzone_y[2], c_stick_deadzone_y[3]];
        values3 = [NSString stringWithFormat:@"%i.%i.%i.%i.%i.%i.%i.%i", l_deadzone[0], l_deadzone[1], l_deadzone[2], l_deadzone[3], r_deadzone[0], r_deadzone[1], r_deadzone[2], r_deadzone[3]];
        values4 = [NSString stringWithFormat:@"%i.%i.%i.%i.%i.%i.%i.%i.%i.%i.%i.%i.%i.%i.%i.%i", disableDeadzones[0], disableDeadzones[1], disableDeadzones[2], disableDeadzones[3], disable_l_analog[0], disable_l_analog[1], disable_l_analog[2], disable_l_analog[3], disable_r_analog[0], disable_r_analog[1], disable_r_analog[2], disable_r_analog[3], disableSticks[0], disableSticks[1], disableSticks[2], disableSticks[3]];
        valuescombined = [NSString stringWithFormat:@"%@.%@.%@.%@", values1, values2, values3, values4];
        [standardUserDefaults setObject:valuescombined forKey:@"deadzones"];
        
        [standardUserDefaults synchronize];
    }
}


- (void) loadDefaultCalibrations {
    for (int i = 0; i < 4; i++) {
        stick_max_x[i] = 103; stick_middle_x[i] = 122;
        stick_max_y[i] = 100; stick_middle_y[i] = 130;
        
        c_stick_max_x[i] = 93; c_stick_middle_x[i] = 128;
        c_stick_max_y[i] = 101; c_stick_middle_y[i] = 132;
        
        l_max[i] = 200; l_middle[i] = 23;
        r_max[i] = 212; r_middle[i] = 22;
        
        stick_deadzone_x[i] = 5;
        stick_deadzone_y[i] = 5;
        c_stick_deadzone_x[i] = 5;
        c_stick_deadzone_y[i] = 5;
        l_deadzone[i] = 5;
        r_deadzone[i] = 5;
        
        disable_l_analog[i] = FALSE;
        disable_r_analog[i] = FALSE;
        disableDeadzones[i] = FALSE;
        disableSticks[i] = FALSE;
    }
}


- (void) restoreDefaultCalibrations {
    /* reset defaults */
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
    
    [self loadDefaultCalibrations];
    [self saveControllerCalibrations];
}


- (void) fillOptionsView: (OptionsViewController *) view {
    int p = view.currentPort;
    view.stickXMiddle.stringValue = [NSString stringWithFormat: @"%d", stick_middle_x[p]];
    view.stickXHigh.stringValue = [NSString stringWithFormat: @"%d", stick_max_x[p]];
    view.stickYMiddle.stringValue = [NSString stringWithFormat: @"%d", stick_middle_y[p]];
    view.stickYHigh.stringValue = [NSString stringWithFormat: @"%d", stick_max_y[p]];
    
    view.cstickXMiddle.stringValue = [NSString stringWithFormat: @"%d", c_stick_middle_x[p]];
    view.cstickXHigh.stringValue = [NSString stringWithFormat: @"%d", c_stick_max_x[p]];
    view.cstickYMiddle.stringValue = [NSString stringWithFormat: @"%d", c_stick_middle_y[p]];
    view.cstickYHigh.stringValue = [NSString stringWithFormat: @"%d", c_stick_max_y[p]];
    
    view.l_Middle.stringValue = [NSString stringWithFormat: @"%d", l_middle[p]];
    view.l_High.stringValue = [NSString stringWithFormat: @"%d", l_max[p]];
    view.r_Middle.stringValue = [NSString stringWithFormat: @"%d", r_middle[p]];
    view.r_High.stringValue = [NSString stringWithFormat: @"%d", r_max[p]];
    
    view.deadzoneX.stringValue = [NSString stringWithFormat: @"%d", stick_deadzone_x[p]];
    view.deadzoneY.stringValue = [NSString stringWithFormat: @"%d", stick_deadzone_y[p]];
    view.cdeadzoneX.stringValue = [NSString stringWithFormat: @"%d", c_stick_deadzone_x[p]];
    view.cdeadzoneY.stringValue = [NSString stringWithFormat: @"%d", c_stick_deadzone_y[p]];
    view.deadzoneL.stringValue = [NSString stringWithFormat: @"%d", l_deadzone[p]];
    view.deadzoneR.stringValue = [NSString stringWithFormat: @"%d", r_deadzone[p]];
    
    view.disableLeftAnalog.state = disable_l_analog[p];
    view.disableRightAnalog.state = disable_r_analog[p];
    view.disableDeadzones.state = disableDeadzones[p];
    view.disableTriggers.state = disableSticks[p];
}


- (void) loadFromOptionsView: (OptionsViewController *) view {
    int p = view.currentPort;
    stick_middle_x[p] = view.stickXMiddle.intValue;
    stick_max_x[p] = view.stickXHigh.intValue;
    stick_middle_y[p] = view.stickYMiddle.intValue;
    stick_max_y[p] = view.stickYHigh.intValue;
    
    c_stick_middle_x[p] = view.cstickXMiddle.intValue;
    c_stick_max_x[p] = view.cstickXHigh.intValue;
    c_stick_middle_y[p] = view.cstickYMiddle.intValue;
    c_stick_max_y[p] = view.cstickYHigh.intValue;
    
    l_middle[p] = view.l_Middle.intValue;
    l_max[p] = view.l_High.intValue;
    r_middle[p] = view.r_Middle.intValue;
    r_max[p] = view.r_High.intValue;
    
    stick_deadzone_x[p] = view.deadzoneX.intValue;
    stick_deadzone_y[p] = view.deadzoneY.intValue;
    c_stick_deadzone_x[p] = view.cdeadzoneX.intValue;
    c_stick_deadzone_y[p] = view.cdeadzoneY.intValue;
    l_deadzone[p] = view.deadzoneL.intValue;
    r_deadzone[p] = view.deadzoneR.intValue;
    
    disable_l_analog[p] = view.disableLeftAnalog.state;
    disable_r_analog[p] = view.disableRightAnalog.state;
    disableDeadzones[p] = view.disableDeadzones.state;
    disableSticks[p] = view.disableTriggers.state;
}


- (void) setCalibration: (int) port : (int) i {
    isBeingCalibrated[port] = i;
}

@end


