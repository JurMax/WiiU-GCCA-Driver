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
int stick_max_x[4], stick_middle_x[4], stick_max_y[4], stick_middle_y[4];
int c_stick_max_x[4], c_stick_middle_x[4], c_stick_max_y[4], c_stick_middle_y[4];
int r_max[4], r_middle[4], l_max[4], l_middle[4];
int stick_deadzone[4], c_stick_deadzone[4], l_and_r_deadzone[4];
bool disable_l_and_r[4] = { TRUE, TRUE, TRUE, TRUE };


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

@end


void cbin(struct libusb_transfer* transfer) {
    unsigned char * p = in_buffer+1;
    unsigned char stickXRaw, stickYRaw;
    float stickX, stickY;
    NSPoint point = NSZeroPoint;
    
    if (transfer -> status > 0){
        printf("asdf\n");
        dispatch_async(dispatch_get_main_queue(), ^{
            Functions *functions = ((ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController).functions;
            [functions addStringtoLog:@"- Something went wrong, the driver has closed. -\n"];
            functions.isInitialized = FALSE;
            [functions stopDriver];
        });
    };
    
    
    for (int i = 0; i < 4; i++) {
        if (p[0] > 4) { /* Is controller inserted*/
            if (!isControllerInserted[i]) {
                isControllerInserted[i] = TRUE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *string = [NSString stringWithFormat: @"  Controller detected in port %i.\n", i + 1];
                    Functions *functions = ((ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController).functions;
                    [functions addStringtoLog: string];
                    [functions validateCalibrateButtons];
                });
                [(Gcc*) (controllers[i]) setup:i];
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
            
            
            stickXRaw = p[3]; // main stick x
            stickYRaw = p[4]; // main stick y
            
            if (stickXRaw <= stick_middle_x[i] + stick_deadzone[i] && stickXRaw >= stick_middle_x[i] - stick_deadzone[i])
                stickXRaw = stick_middle_x[i];
            if (stickYRaw <= stick_middle_y[i] + stick_deadzone[i] && stickYRaw >= stick_middle_y[i] - stick_deadzone[i])
                stickYRaw = stick_middle_y[i];
            stickX = (float) (stickXRaw - stick_middle_x[i]) / (float) stick_max_x[i];
            stickY = (float) (stickYRaw - stick_middle_y[i]) / (float) stick_max_y[i];
            
            point.x = stickX;
            point.y = stickY;
            [VHID setPointer:0 position:point];
            
            
            stickXRaw = p[7]; // l-analog (25 to 242)
            stickYRaw = p[5]; // c-stick x
            
            if (stickXRaw <= l_middle[i] + l_and_r_deadzone[i])
                stickXRaw = l_middle[i];
            if (stickYRaw <= c_stick_middle_x[i] + c_stick_deadzone[i] && stickYRaw >= c_stick_middle_x[i] - c_stick_deadzone[i])
                stickYRaw = c_stick_middle_x[i];
            stickX = (float) (stickXRaw - l_middle[i]) / (float) l_max[i];
            stickY = -(float) (stickYRaw - c_stick_middle_x[i]) / (float) stick_max_x[i];
            if (disable_l_and_r[i])
                stickX = 0.0;
            
            point.x = stickX;
            point.y = stickY;
            [VHID setPointer:1 position:point];
            
            
            stickXRaw = p[6];  // c-stick y
            stickYRaw = p[8];  // r-analog
            if (stickXRaw <= c_stick_middle_y[i] + c_stick_deadzone[i] && stickYRaw >= c_stick_middle_y[i] - c_stick_deadzone[i])
                stickXRaw = c_stick_middle_y[i];
            if (stickYRaw <= r_middle[i] + l_and_r_deadzone[i])
                stickYRaw = r_middle[i];
            stickX = (float) (stickXRaw - c_stick_middle_y[i]) / (float) stick_max_y[i];
            stickY = (float) (stickYRaw - r_middle[i]) / (float) r_max[i];
            if (disable_l_and_r[i])
                stickY = 0.0;
            
            point.x = stickX;
            point.y = stickY;
            [VHID setPointer:2 position:point];
        }
        else {
            VHIDDevice *VHID = [controllers[i] VHID];
            point.x = 0;
            point.y = 0;
            [VHID setPointer:0 position:point];
            [VHID setPointer:1 position:point];
            [VHID setPointer:2 position:point];
            
            if (isControllerInserted[i]) {
                isControllerInserted[i] = FALSE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *string = @""; string = [string stringByAppendingFormat:@"  Controller removed from port %i.\n", i + 1];
                    Functions *functions = ((ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController).functions;
                    [functions addStringtoLog: string];
                    [functions validateCalibrateButtons];
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

- (int) setup {
    
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
                if(count==0) r_max[0] = i;  if(count==1) r_max[1] = i;  if(count==2) r_max[2] = i;  if(count==3) r_max[3] = i;
                if(count==4) r_middle[0] = i;  if(count==5) r_middle[1] = i;  if(count==6) r_middle[2] = i;  if(count==7) r_middle[3] = i;
                if(count==8) l_max[0] = i;  if(count==9) l_max[1] = i;  if(count==10) l_max[2] = i;  if(count==11) l_max[3] = i;
                if(count==12) l_middle[0] = i;  if(count==13) l_middle[1] = i;  if(count==14) l_middle[2] = i;  if(count==15) l_middle[3] = i;
                count++;
            }
            
            count = 0;
            stickString = [standardUserDefaults objectForKey:@"deadzones"];
            listItems = [stickString componentsSeparatedByString:@"."];
            for (id value in listItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) stick_deadzone[0] = i;  if(count==1) stick_deadzone[1] = i;
                if(count==2) stick_deadzone[2] = i;  if(count==3) stick_deadzone[3] = i;
                if(count==4) c_stick_deadzone[0] = i;  if(count==5) c_stick_deadzone[1] = i;
                if(count==6) c_stick_deadzone[2] = i;  if(count==7) c_stick_deadzone[3] = i;
                if(count==8) l_and_r_deadzone[0] = i;  if(count==9) l_and_r_deadzone[1] = i;
                if(count==10) l_and_r_deadzone[2] = i;  if(count==11) l_and_r_deadzone[3] = i;
                count++;
            }
        } else {
            [((ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController).functions addStringtoLog:@"  No controller calibrations found, using defaults."];
            [self loadDefaultCalibrations];
        }
    }
}


- (void) saveControllerCalibrations {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSString *maxx = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_max_x[0], stick_max_x[1], stick_max_x[2], stick_max_x[3]];
        NSString *middlex = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_middle_x[0], stick_middle_x[1], stick_middle_x[2], stick_middle_x[3]];
        NSString *maxy = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_max_y[0], stick_max_y[1], stick_max_y[2], stick_max_y[3]];
        NSString *middley = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_middle_y[0], stick_middle_y[1], stick_middle_y[2], stick_middle_y[3]];
        NSString *values = [NSString stringWithFormat:@"%@.%@.%@.%@", maxx, middlex, maxy, middley];
        [standardUserDefaults setObject:values forKey:@"stick"];
        
        maxx = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_max_x[0], c_stick_max_x[1], c_stick_max_x[2], c_stick_max_x[3]];
        middlex = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_middle_x[0], c_stick_middle_x[1], c_stick_middle_x[2], c_stick_middle_x[3]];
        maxy = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_max_y[0], c_stick_max_y[1], c_stick_max_y[2], c_stick_max_y[3]];
        middley = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_middle_y[0], c_stick_middle_y[1], c_stick_middle_y[2], c_stick_middle_y[3]];
        values = [NSString stringWithFormat:@"%@.%@.%@.%@", maxx, middlex, maxy, middley];
        [standardUserDefaults setObject:values forKey:@"c_stick"];
        
        maxx = [NSString stringWithFormat:@"%i.%i.%i.%i", r_max[0], r_max[1], r_max[2], r_max[3]];
        middlex = [NSString stringWithFormat:@"%i.%i.%i.%i", r_middle[0], r_middle[1], r_middle[2], r_middle[3]];
        maxy = [NSString stringWithFormat:@"%i.%i.%i.%i", l_max[0], l_max[1], l_max[2], l_max[3]];
        middley = [NSString stringWithFormat:@"%i.%i.%i.%i", l_middle[0], l_middle[1], l_middle[2], l_middle[3]];
        values = [NSString stringWithFormat:@"%@.%@.%@.%@", maxx, middlex, maxy, middley];
        [standardUserDefaults setObject:values forKey:@"l_and_r"];
        
        maxx = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_deadzone[0], stick_deadzone[1], stick_deadzone[2], stick_deadzone[3]];
        middlex = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_deadzone[0], c_stick_deadzone[1], c_stick_deadzone[2], c_stick_deadzone[3]];
        maxy = [NSString stringWithFormat:@"%i.%i.%i.%i", l_and_r_deadzone[0], l_and_r_deadzone[1], l_and_r_deadzone[2], l_and_r_deadzone[3]];
        values = [NSString stringWithFormat:@"%@.%@.%@", maxx, middlex, maxy];
        [standardUserDefaults setObject:values forKey:@"deadzones"];
        
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
        
        stick_deadzone[i] = 5;
        c_stick_deadzone[i] = 30;
        l_and_r_deadzone[i] = 5;
    }
    
    [self saveControllerCalibrations];
}

- (void) restoreDefaultCalibrations {
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
    //int port = view.currentPort;
    
    
}

@end


