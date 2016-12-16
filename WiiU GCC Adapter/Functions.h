//
//  Functions.h
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 21-02-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AdapterHandler.h"
#import "ViewController.h"


@class ViewController;
@class OptionsViewController;
@class GccManager;


@interface Functions : NSObject

@property ViewController *mainViewController;
@property OptionsViewController *optionsViewController;
@property GccManager *gccManager;

@property bool isDriverInitialized;
@property bool isDriverClosed;
@property bool isDriverRunning;
@property long int driverRunningTime;

@property int currentPortSettings; /* to determine which controller is being edited in the optionsView */
@property bool advancedSettings;

@property NSString *logString;


- (void) startDriver;
- (void) initializeAdapter:(bool) runDriver;
- (void) runDriver;
- (void) stopDriver;

- (void) startProgressBar:(float) seconds;
- (void) calibrateControllers:(int) tag;
- (void) validateCalibrateButtons;

- (void) addStringtoLog:(NSString*) string;

@end


