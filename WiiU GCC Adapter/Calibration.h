//
//  Calibration.h
//  wiiu-gcc-adapter
//
//  Created by Jurriaan van den Berg on 03-05-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import "ViewController.h"
#import "OptionsViewController.h"


@class OptionsViewController;


extern int stick_max_x[4], stick_middle_x[4], stick_max_y[4], stick_middle_y[4];
extern int c_stick_max_x[4], c_stick_middle_x[4], c_stick_max_y[4], c_stick_middle_y[4];
extern int r_max[4], r_middle[4], l_max[4], l_middle[4];

extern int stick_deadzone_x[4], stick_deadzone_y[4];
extern int c_stick_deadzone_x[4], c_stick_deadzone_y[4];
extern int l_deadzone[4], r_deadzone[4];

extern bool disable_l_analog[4];
extern bool disable_r_analog[4];
extern bool disableDeadzones[4];
extern bool disableSticks[4];

extern int calibrationState[4];


@interface Calibration : NSObject

+ (void) loadControllerCalibrations;
+ (void) saveControllerCalibrations;
+ (void) loadDefaultCalibrations;
+ (void) restoreDefaultCalibrations;

+ (void) setCalibration:(int) port state:(int) i;
+ (void) fillOptionsView:(OptionsViewController *) view;
+ (void) setDeadzoneTextFieldStates:(OptionsViewController *) view;
+ (void) loadFromOptionsView:(OptionsViewController *) view;

@end


