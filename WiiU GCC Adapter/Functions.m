//
//  Functions.m
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 21-02-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import "Functions.h"


@implementation Functions

@synthesize mainViewController;
@synthesize optionsViewController;
@synthesize gccManager;

@synthesize isDriverInitialized;
@synthesize isDriverClosed;
@synthesize isDriverRunning;
@synthesize driverRunningTime;

@synthesize currentPortSettings;
@synthesize advancedSettings;

@synthesize logString;


- (id) init {
    if (self = [super init]) {
        gccManager = [[GccManager alloc] init];
        
        isDriverInitialized = false;
        isDriverRunning = false;
        isDriverClosed = true;
        driverRunningTime = 0;
        
        currentPortSettings = -1;
        advancedSettings = false;
        
        logString = @"";
    }
    return self;
}


- (void) startDriver {
    [self addStringtoLog: @"- Starting driver. -\n"];
    
    [Calibration loadControllerCalibrations];

    if (!isDriverInitialized) {
        [self initializeAdapter: true];
    } else {
        [self runDriver];
    }
}


- (void) initializeAdapter:(bool) runDriver {
    mainViewController.initializeAdapterButton.enabled = NO;
    mainViewController.startButton.enabled = NO;
    mainViewController.stopButton.enabled = NO;
    
    [self addStringtoLog:@"  Initializing adapter...\n"];
    [self startProgressBar: 3.0];
    
    if (isDriverRunning) {
        [self stopDriver];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (isDriverInitialized) {
            [gccManager reset];
        }
        
        int i = [gccManager setup: self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (i == 1) {
                isDriverInitialized = true;
                [self addStringtoLog:@"  Adapter initialised. \n"];
            } else {
                isDriverInitialized = false;
                [self addStringtoLog:@"- WiiU GCC adapter not detected. -\n"];
                [mainViewController.progressBar setDoubleValue: -999.0];
            }
            
            mainViewController.initializeAdapterButton.enabled = YES;
            mainViewController.startButton.enabled = YES;
            
            if (runDriver && isDriverInitialized) {
                [self runDriver];
            }
        });
    });
}


- (void) runDriver {
    mainViewController.startButton.enabled = NO;
    mainViewController.stopButton.enabled = YES;
    mainViewController.initializeAdapterButton.enabled = YES;
    
    [self addStringtoLog:@"- Driver succesfully started. -\n"];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        isDriverRunning = true;
        driverRunningTime = [[NSDate date] timeIntervalSince1970];
    
        while (isDriverRunning) {
            isDriverClosed = false;
            [gccManager update];
        }
    
        isDriverClosed = true;
    });
}


- (void) stopDriver {
    if (isDriverInitialized) {
        isDriverRunning = false;
        
        while (!isDriverClosed) {}  /* make sure the driver has stopped */
        
        long int time = ([[NSDate date] timeIntervalSince1970] - driverRunningTime) * 1000;
        NSString *string = [NSString stringWithFormat: @"- Driver closed. (%li ms) -\n\n", time];
        [self addStringtoLog: string];
        
        [gccManager removeControllers];
    
        mainViewController.startButton.enabled = YES;
        mainViewController.stopButton.enabled = NO;
    }
}





/* A really unnecessary progress bar */
- (void) startProgressBar: (float) seconds {
    NSProgressIndicator *progressbar = mainViewController.progressBar;
    
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
            bool adapterNotLoaded = progressbar.doubleValue == -999.0;
            if (adapterNotLoaded) {
                printf("notloaded\n");
                [progressbar setDoubleValue: 0.0];
            } else {
                [progressbar setDoubleValue: 100.0];
            }
        });
    });
}


- (void) calibrateControllers:(int) tag {
    currentPortSettings = tag - 1;
}


- (void) validateCalibrateButtons {
    [self mainViewController].calibrateButton1.enabled = [gccManager isControllerInserted:0];
    [self mainViewController].calibrateButton2.enabled = [gccManager isControllerInserted:1];
    [self mainViewController].calibrateButton3.enabled = [gccManager isControllerInserted:2];
    [self mainViewController].calibrateButton4.enabled = [gccManager isControllerInserted:3];
}


- (void) addStringtoLog:(NSString*) string {
    NSLog(@"Log: %@", string);
    
    NSString *currentString = logString;
    if (currentString == NULL) {
        currentString = @"";
    }
    
    logString = [NSString stringWithFormat: @"%@%@", currentString, string];
    
    [[self mainViewController].largeTextView setString:logString];
}

@end


