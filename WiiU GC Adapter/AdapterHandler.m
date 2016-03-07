//
//  main.m
//  wiiu-gcc-adapter
//
//  A lot of this is based on work by Mitch Dzugan - many thanks to him!

#import "AdapterHandler.h"


const float DEADZONE = 20;
//const float MAX_VALUE = 10;

struct libusb_transfer *transfer_in = NULL; // IN-coming transfers (IN to host PC from USB-device)
unsigned char in_buffer[38];

NSArray *controllers;
int stick_max_x[4], stick_min_x[4], stick_max_y[4], stick_min_y[4];
int c_stick_max_x[4], c_stick_min_x[4], c_stick_max_y[4], c_stick_min_y[4];
int r_max[4], r_min[4], l_max[4], l_min[4];


@implementation Gcc
@synthesize VHID;
@synthesize virtualDevice;

void cbin(struct libusb_transfer* transfer) {
    unsigned char * p = in_buffer+1;
    unsigned char stickXRaw, stickYRaw;
    float stickX, stickY;
    NSPoint point = NSZeroPoint;
    
    if (transfer -> status > 0){
        //Something went wrong, so exit
        dispatch_async(dispatch_get_main_queue(), ^{
            NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
            Functions *functions = ((ViewController *) mainWindow.contentViewController).functions;
            [functions addStringtoLog:@"- Something went wrong, the driver has closed. -\n"];
            functions.isInitialized = FALSE;
            functions.isDriverRunning = FALSE;
        });
    };
    
    
    for (int i = 0; i < 4; i++) {
        if (p[0] > 0) {
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
            
            stickXRaw = p[3];
            stickYRaw = p[4];
            if ((float)stickXRaw > 128 + DEADZONE) {
            } else {
                stickX = 0;
            }
            stickX = (float)stickXRaw / (128.0) - 1.0;
            stickY = (float)stickYRaw / (128.0) - 1.0;
            
            if (i == 0){
                if (stickX > 0.1) {
                    printf("x: %f, %f\n", (float) stickX, (float)stickXRaw);
                    printf("y: %f, %f\n", (float) stickY, (float)stickYRaw);
                }
            }
            point.x = stickX;
            point.y = stickY;
            [VHID setPointer:0 position:point];
            
            stickXRaw = 0;//p[7]; // dit is de l-analog ding: gaat van 25 tot 242
            stickYRaw = p[5];
            stickX = (float)stickXRaw / (128.0) - 1.0;
            stickY = -(float)stickYRaw / (128.0) + 1.0;
            point.x = 0;
            point.y = stickY;
            [VHID setPointer:1 position:point];
            
            stickXRaw = p[6];
            stickYRaw = 0;//p[8];  // dit is de r-analog ding
            stickX = -(float)stickXRaw / (128.0) + 1.0;
            stickY = -(float)stickYRaw / (128.0) + 1.0;
            point.x = 0;
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
        }
        p += 9;
    }
    libusb_submit_transfer(transfer_in);
}

- (Gcc *)setup:(int)ind {
    [WJoyDevice prepare];
    VHID = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeJoystick pointerCount:3 buttonCount:12 isRelative:NO];
    
    NSDictionary *properties = @{ WJoyDeviceProductStringKey : ( [NSString stringWithFormat: @"WiiU GCC Port  %@", @[@"1", @"2", @"3", @"4"] [ind]] ),
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



@implementation GccManager
@synthesize dev_handle;

@synthesize r;
@synthesize ctx;

- (int) setup {
    [self loadControllerCalibrations];
    [self saveControllerCalibrations];
    /*
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

    controllers = @[[[[Gcc alloc] init] setup:0],
                    [[[Gcc alloc] init] setup:1],
                    [[[Gcc alloc] init] setup:2],
                    [[[Gcc alloc] init] setup:3]];
    
    transfer_in  = libusb_alloc_transfer(0);
    libusb_fill_bulk_transfer( transfer_in, dev_handle, (1 | LIBUSB_ENDPOINT_IN),
                              in_buffer,  37,  // Note: in_buffer is where input data is written.
                              cbin, NULL, 0); // no user data
    r = libusb_submit_transfer(transfer_in);

    [self loadControllerCalibrations];
    */
    return 1;
}


- (void) reset {
    [controllers[0] remove];
    [controllers[1] remove];
    [controllers[2] remove];
    [controllers[3] remove];
    libusb_cancel_transfer(transfer_in);
    libusb_release_interface(dev_handle, 0);
}


- (void) update {
    r = libusb_handle_events_completed(ctx, NULL);
}


- (void) loadControllerCalibrations {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *stickString = nil;
    
    if (standardUserDefaults) {
        stickString = [standardUserDefaults objectForKey:@"stick"];
        short int count;
        
        if (stickString != NULL) {
            
            stickString = [standardUserDefaults objectForKey:@"stick"];
            NSArray *listItems = [stickString componentsSeparatedByString:@"-"];
            count = 0;
            for (id value in listItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) stick_max_x[0] = i;  if(count==1) stick_max_x[1] = i;
                if(count==2) stick_max_x[2] = i;  if(count==3) stick_max_x[3] = i;
                if(count==4) stick_min_x[0] = i;  if(count==5) stick_min_x[1] = i;
                if(count==6) stick_min_x[2] = i;  if(count==7) stick_min_x[3] = i;
                if(count==8) stick_max_y[0] = i;  if(count==9) stick_max_y[1] = i;
                if(count==10) stick_max_y[2] = i;  if(count==11) stick_max_y[3] = i;
                if(count==12) stick_min_y[0] = i;  if(count==13) stick_min_y[1] = i;
                if(count==14) stick_min_y[2] = i;  if(count==15) stick_min_y[3] = i;
                count++;
            }
            
            stickString = [standardUserDefaults objectForKey:@"c_stick"];
            listItems = [stickString componentsSeparatedByString:@"-"];
            count = 0;
            for (id value in listItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) c_stick_max_x[0] = i;  if(count==1) c_stick_max_x[1] = i;
                if(count==2) c_stick_max_x[2] = i;  if(count==3) c_stick_max_x[3] = i;
                if(count==4) c_stick_min_x[0] = i;  if(count==5) c_stick_min_x[1] = i;
                if(count==6) c_stick_min_x[2] = i;  if(count==7) c_stick_min_x[3] = i;
                if(count==8) c_stick_max_y[0] = i;  if(count==9) c_stick_max_y[1] = i;
                if(count==10) c_stick_max_y[2] = i;  if(count==11) c_stick_max_y[3] = i;
                if(count==12) c_stick_min_y[0] = i;  if(count==13) c_stick_min_y[1] = i;
                if(count==14) c_stick_min_y[2] = i;  if(count==15) c_stick_min_y[3] = i;
                count++;
            }
            
            count = 0;
            stickString = [standardUserDefaults objectForKey:@"l_and_r"];
            listItems = [stickString componentsSeparatedByString:@"-"];
            for (id value in listItems) {
                printf("%i", count);
                int i = [((NSString*) value) intValue];
                if(count==0) r_max[0] = i;  if(count==1) r_max[1] = i;  if(count==2) r_max[2] = i;  if(count==3) r_max[3] = i;
                if(count==4) r_min[0] = i;  if(count==5) r_min[1] = i;  if(count==6) r_min[2] = i;  if(count==7) r_min[3] = i;
                if(count==8) l_max[0] = i;  if(count==9) l_max[1] = i;  if(count==10) l_max[2] = i;  if(count==11) l_max[3] = i;
                if(count==12) l_min[0] = i;  if(count==13) l_min[1] = i;  if(count==14) l_min[2] = i;  if(count==15) l_min[3] = i;
                count++;
            }
            
        } else {
            [((ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController).functions addStringtoLog:@" Using default controller calibrations."];
            [self loadDefaultCalibrations];
        }
    }
}

- (void) saveControllerCalibrations {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSString *maxx = [NSString stringWithFormat:@"%i-%i-%i-%i", stick_max_x[0], stick_max_x[1], stick_max_x[2], stick_max_x[3]];
        NSString *minx = [NSString stringWithFormat:@"%i-%i-%i-%i", stick_min_x[0], stick_min_x[1], stick_min_x[2], stick_min_x[3]];
        NSString *maxy = [NSString stringWithFormat:@"%i-%i-%i-%i", stick_max_y[0], stick_max_y[1], stick_max_y[2], stick_max_y[3]];
        NSString *miny = [NSString stringWithFormat:@"%i-%i-%i-%i", stick_min_y[0], stick_min_y[1], stick_min_y[2], stick_min_y[3]];
        NSString *values = [NSString stringWithFormat:@"%@-%@-%@-%@", maxx, minx, maxy, miny];
        [standardUserDefaults setObject:values forKey:@"stick"];
        [standardUserDefaults synchronize];
        
        maxx = [NSString stringWithFormat:@"%i-%i-%i-%i", c_stick_max_x[0], c_stick_max_x[1], c_stick_max_x[2], c_stick_max_x[3]];
        minx = [NSString stringWithFormat:@"%i-%i-%i-%i", c_stick_min_x[0], c_stick_min_x[1], c_stick_min_x[2], c_stick_min_x[3]];
        maxy = [NSString stringWithFormat:@"%i-%i-%i-%i", c_stick_max_y[0], c_stick_max_y[1], c_stick_max_y[2], c_stick_max_y[3]];
        miny = [NSString stringWithFormat:@"%i-%i-%i-%i", c_stick_min_y[0], c_stick_min_y[1], c_stick_min_y[2], c_stick_min_y[3]];
        values = [NSString stringWithFormat:@"%@-%@-%@-%@", maxx, minx, maxy, miny];
        [standardUserDefaults setObject:values forKey:@"c_stick"];
        [standardUserDefaults synchronize];
        
        maxy = [NSString stringWithFormat:@"%i-%i-%i-%i", r_max[0], r_max[1], r_max[2], r_max[3]];
        minx = [NSString stringWithFormat:@"%i-%i-%i-%i", r_min[0], r_min[1], r_min[2], r_min[3]];
        maxy = [NSString stringWithFormat:@"%i-%i-%i-%i", l_max[0], l_max[1], l_max[2], l_max[3]];
        miny = [NSString stringWithFormat:@"%i-%i-%i-%i", l_min[0], l_min[1], l_min[2], l_min[3]];
        values = [NSString stringWithFormat:@"%@-%@-%@-%@", maxx, minx, maxy, miny];
        [standardUserDefaults setObject:values forKey:@"l_and_r"];
        [standardUserDefaults synchronize];
    }
}

- (void) loadDefaultCalibrations {
    //TODO
    
    [self saveControllerCalibrations];
}

@end


