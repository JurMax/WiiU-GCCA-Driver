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
@synthesize logString;
@synthesize gccManager;
-(id)init {
    if (self = [super init]) {
        isInitialized = FALSE;
        isDriverRunning = FALSE;
        logString = @"";
        gccManager = [[GccManager alloc] init];
    }
    return self;
}

bool isClosed = TRUE;

- (void) addStringtoLog: (NSString*) string {
    NSLog(@"%@", string);
    NSString *currentString = logString;
    if (currentString == NULL) {
        currentString = @"";
    }
    logString = [NSString stringWithFormat: @"%@%@", currentString, string];
    
    ViewController *viewController2 = (ViewController*) [[NSApplication sharedApplication] mainWindow].contentViewController;
    [viewController2.largeTextView setString:logString];
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
        while (!isClosed) {};
        [gccManager reset];
        isInitialized = false;
    }
    int i = [gccManager setup];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (i == 1) {
            [self addStringtoLog:@"  Adapter initialised. \n"];
            isInitialized = TRUE;
        } else {
            [self addStringtoLog:@"- WiiU GCC adapter not detected! -\n"];
            //TODO stop the progressbar
            isInitialized = FALSE;
        }
        [self getViewController].initializeAdapterButton.enabled = YES;
        [self getViewController].startButton.enabled = YES;
        [self getViewController].stopButton.enabled = NO;
    });

}


- (void) startDriver {
    [self getViewController].startButton.enabled = NO;
    [self getViewController].stopButton.enabled = NO;
    [self getViewController].initializeAdapterButton.enabled = NO;
    
    if (!isInitialized) {
        [self addStringtoLog: @"- Starting driver. -\n"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self initializeAdapter];
            if (isInitialized) {
                [self runDriver];
            }
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self runDriver];
        });
    }
}


- (void) stopDriver {
    isDriverRunning = FALSE;
    
    while (!isClosed) {}; /* to make sure the driver isn't running */
    [self addStringtoLog: @"- Driver closed. -\n"];
    [self getViewController].startButton.enabled = YES;
    [self getViewController].stopButton.enabled = NO;
}


- (void) runDriver {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addStringtoLog:@"- Driver succesfully started. -\n"];
        [self getViewController].startButton.enabled = NO;
        [self getViewController].stopButton.enabled = YES;
        [self getViewController].initializeAdapterButton.enabled = YES;
    });
    
    isDriverRunning = TRUE;
    while (isDriverRunning) {
        [gccManager update];
        isClosed = FALSE;
    }
    isClosed = TRUE;
}


/* v A really unnecessary progress bar v */
- (void) startProgressBar: (float) seconds {
    NSProgressIndicator *progressbar = [self getViewController].progressBar;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        double start = timeInMiliseconds;
        double current = 0;
        while (current < seconds) {
            current = [[NSDate date] timeIntervalSince1970] - start;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                double progress = (current / seconds) * 100;
                [progressbar setDoubleValue: progress];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressbar setDoubleValue: 100];
        });
    });
}



- (ViewController*) getViewController {
    return (ViewController*) [[NSApplication sharedApplication] mainWindow].contentViewController;
}

@end