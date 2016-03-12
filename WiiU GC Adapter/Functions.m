//
//  Functions.m
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 21-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import "Functions.h"

@implementation Functions

@synthesize isInitialized;
@synthesize isDriverRunning;
@synthesize driverRunningTime;
@synthesize logString;
@synthesize gccManager;
@synthesize currentCalibration;
-(id)init {
    if (self = [super init]) {
        isInitialized = FALSE;
        isDriverRunning = FALSE;
        driverRunningTime = 0;
        logString = @"";
        gccManager = [[GccManager alloc] init];
        currentCalibration = 0;
    }
    return self;
}

bool isDriverClosed = TRUE;


- (void) addStringtoLog: (NSString*) string {
    NSLog(@"Log: %@", string);
    NSString *currentString = logString;
    if (currentString == NULL) {
        currentString = @"";
    }
    logString = [NSString stringWithFormat: @"%@%@", currentString, string];
    
    ViewController *viewController2 = (ViewController*) [[NSApplication sharedApplication] mainWindow].contentViewController;
    [viewController2.largeTextView setString:logString];
}


- (void) startDriver {
    [self getViewController].startButton.enabled = NO;
    [self getViewController].stopButton.enabled = NO;
    [self getViewController].initializeAdapterButton.enabled = NO;
    
    if (!isInitialized) {
        [self addStringtoLog: @"- Starting driver. -\n"];
        
        [gccManager loadControllerCalibrations];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self initializeAdapter];
            if (isInitialized)
                [self runDriver];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self runDriver];
        });
    }
}


- (void) stopDriver {
    isDriverRunning = FALSE;
    
    if (isInitialized) {
        while (!isDriverClosed) {}; /* make sure the driver isn't running */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [gccManager removeControllers];
        });
    
        long int time = ([[NSDate date] timeIntervalSince1970] - driverRunningTime) * 1000;
        NSString *string = [NSString stringWithFormat: @"- Driver closed. (%li ms) -\n\n", time];
        [self addStringtoLog: string];
        [self getViewController].startButton.enabled = YES;
        [self getViewController].stopButton.enabled = NO;
        [self validateCalibrateButtons];
    }
}


- (void) runDriver {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addStringtoLog:@"- Driver succesfully started. -\n"];
        [self getViewController].startButton.enabled = NO;
        [self getViewController].stopButton.enabled = YES;
        [self getViewController].initializeAdapterButton.enabled = YES;
    });
    
    isDriverRunning = TRUE;
    driverRunningTime = [[NSDate date] timeIntervalSince1970];
    while (isDriverRunning) {
        isDriverClosed = FALSE;
        [gccManager update];
    }
    isDriverClosed = TRUE;
}


- (void) initializeAdapterOnly {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self initializeAdapter];
    });
}


- (void) initializeAdapter {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isDriverRunning) {
            [self stopDriver];
        }
        [self addStringtoLog:@"  Initializing adapter...\n"];
        [self getViewController].initializeAdapterButton.enabled = NO;
        [self getViewController].startButton.enabled = NO;
        [self getViewController].stopButton.enabled = NO;
        
        [self startProgressBar: 3.0];
    });
    
    if (isInitialized) {
        while (!isDriverClosed) {};
        isInitialized = false;
        [gccManager reset];
    }
    int i = [gccManager setup];
    
    __block bool messagedone = FALSE;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (i == 1) {
            isInitialized = TRUE;
            [self addStringtoLog:@"  Adapter initialised. \n"];
            [self validateCalibrateButtons];
        } else {
            isInitialized = FALSE;
            [self addStringtoLog:@"- WiiU GCC adapter not detected! -\n"];
            [[self getViewController].progressBar setDoubleValue: -100.0];
        }
        [self getViewController].initializeAdapterButton.enabled = YES;
        [self getViewController].startButton.enabled = YES;
        messagedone = TRUE;
    });
    while (!messagedone) {}
}


/* v A really unnecessary progress bar v */
- (void) startProgressBar: (float) seconds {
    NSProgressIndicator *progressbar = [self getViewController].progressBar;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        double start = [[NSDate date] timeIntervalSince1970];
        double current = 0;
        while (current < seconds) {
            current = [[NSDate date] timeIntervalSince1970] - start;
            
            if (progressbar.doubleValue != -100.0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    double progress = (current / seconds) * 100;
                    [progressbar setDoubleValue: progress];
                });
            } else {
                current = seconds + 1;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressbar.doubleValue != -100.0) {
                [progressbar setDoubleValue: 100.0];
            } else {
                [progressbar setDoubleValue: 0.0];
            }
        });
    });
}


- (void) calibrateControllers: (int) tag {
    currentCalibration = tag - 1;
    [self validateCalibrateButtons];
}

- (void) validateCalibrateButtons {
    [self getViewController].calibrateButton1.enabled = TRUE; //[gccManager isControllerInserted:0];
    [self getViewController].calibrateButton2.enabled = [gccManager isControllerInserted:1];
    [self getViewController].calibrateButton3.enabled = [gccManager isControllerInserted:2];
    [self getViewController].calibrateButton4.enabled = [gccManager isControllerInserted:3];
}


- (ViewController*) getViewController {
    return (ViewController*) [[NSApplication sharedApplication] mainWindow].contentViewController;
}

@end

