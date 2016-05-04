//
//  Calibration.m
//  wiiu-gcc-adapter
//
//  Created by Jurriaan van den Berg on 03-05-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import "Calibration.h"


int stick_max_x[4], stick_middle_x[4], stick_max_y[4], stick_middle_y[4];
int c_stick_max_x[4], c_stick_middle_x[4], c_stick_max_y[4], c_stick_middle_y[4];
int r_max[4], r_middle[4], l_max[4], l_middle[4];

int stick_deadzone_x[4], stick_deadzone_y[4];
int c_stick_deadzone_x[4], c_stick_deadzone_y[4];
int l_deadzone[4], r_deadzone[4];

bool disable_l_analog[4];
bool disable_r_analog[4];
bool disableDeadzones[4];
bool disableSticks[4];

int calibrationState[4] = { 0, 0, 0, 0 };


@implementation Calibration

+ (void) loadControllerCalibrations {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    bool userDefaultsExist = standardUserDefaults;
    if (userDefaultsExist) {
        NSString *keyString;
        NSArray *keyItems;
        short int count;
        
        bool userDefaultsExist = [standardUserDefaults objectForKey:@"stick_calibration"] != NULL;
        if (userDefaultsExist) {
            
            keyString = [standardUserDefaults objectForKey:@"stick_calibration"];
            keyItems = [keyString componentsSeparatedByString:@"."];
            count = 0;
            for (id value in keyItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) stick_max_x[0] = i;        if(count==1) stick_max_x[1] = i;
                if(count==2) stick_max_x[2] = i;        if(count==3) stick_max_x[3] = i;
                if(count==4) stick_middle_x[0] = i;     if(count==5) stick_middle_x[1] = i;
                if(count==6) stick_middle_x[2] = i;     if(count==7) stick_middle_x[3] = i;
                if(count==8) stick_max_y[0] = i;        if(count==9) stick_max_y[1] = i;
                if(count==10) stick_max_y[2] = i;       if(count==11) stick_max_y[3] = i;
                if(count==12) stick_middle_y[0] = i;    if(count==13) stick_middle_y[1] = i;
                if(count==14) stick_middle_y[2] = i;    if(count==15) stick_middle_y[3] = i;
                count++;
            }
            
            
            keyString = [standardUserDefaults objectForKey:@"c_stick_calibration"];
            keyItems = [keyString componentsSeparatedByString:@"."];
            count = 0;
            for (id value in keyItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) c_stick_max_x[0] = i;      if(count==1) c_stick_max_x[1] = i;
                if(count==2) c_stick_max_x[2] = i;      if(count==3) c_stick_max_x[3] = i;
                if(count==4) c_stick_middle_x[0] = i;   if(count==5) c_stick_middle_x[1] = i;
                if(count==6) c_stick_middle_x[2] = i;   if(count==7) c_stick_middle_x[3] = i;
                if(count==8) c_stick_max_y[0] = i;      if(count==9) c_stick_max_y[1] = i;
                if(count==10) c_stick_max_y[2] = i;     if(count==11) c_stick_max_y[3] = i;
                if(count==12) c_stick_middle_y[0] = i;  if(count==13) c_stick_middle_y[1] = i;
                if(count==14) c_stick_middle_y[2] = i;  if(count==15) c_stick_middle_y[3] = i;
                count++;
            }
            
            
            keyString = [standardUserDefaults objectForKey:@"l_and_r_calibration"];
            keyItems = [keyString componentsSeparatedByString:@"."];
            count = 0;
            for (id value in keyItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) r_max[0] = i;          if(count==1) r_max[1] = i;
                if(count==2) r_max[2] = i;          if(count==3) r_max[3] = i;
                if(count==4) r_middle[0] = i;       if(count==5) r_middle[1] = i;
                if(count==6) r_middle[2] = i;       if(count==7) r_middle[3] = i;
                if(count==8) l_max[0] = i;          if(count==9) l_max[1] = i;
                if(count==10) l_max[2] = i;         if(count==11) l_max[3] = i;
                if(count==12) l_middle[0] = i;      if(count==13) l_middle[1] = i;
                if(count==14) l_middle[2] = i;      if(count==15) l_middle[3] = i;
                count++;
            }
            
            
            keyString = [standardUserDefaults objectForKey:@"deadzones"];
            keyItems = [keyString componentsSeparatedByString:@"."];
            count = 0;
            for (id value in keyItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) stick_deadzone_x[0] = i;  if(count==1) stick_deadzone_x[1] = i;
                if(count==2) stick_deadzone_x[2] = i;  if(count==3) stick_deadzone_x[3] = i;
                if(count==4) stick_deadzone_y[0] = i;  if(count==5) stick_deadzone_y[1] = i;
                if(count==6) stick_deadzone_y[2] = i;  if(count==7) stick_deadzone_y[3] = i;
                
                if(count==8) c_stick_deadzone_x[0] = i;   if(count==9) c_stick_deadzone_x[1] = i;
                if(count==10) c_stick_deadzone_x[2] = i;  if(count==11) c_stick_deadzone_x[3] = i;
                if(count==12) c_stick_deadzone_y[0] = i;  if(count==13) c_stick_deadzone_y[1] = i;
                if(count==14) c_stick_deadzone_y[2] = i;  if(count==15) c_stick_deadzone_y[3] = i;
                
                if(count==16) l_deadzone[0] = i;  if(count==17) l_deadzone[1] = i;
                if(count==18) l_deadzone[2] = i;  if(count==19) l_deadzone[3] = i;
                if(count==20) r_deadzone[0] = i;  if(count==21) r_deadzone[1] = i;
                if(count==22) r_deadzone[2] = i;  if(count==23) r_deadzone[3] = i;
                
                count++;
            }
            
            
            keyString = [standardUserDefaults objectForKey:@"controller_options"];
            keyItems = [keyString componentsSeparatedByString:@"."];
            count = 0;
            for (id value in keyItems) {
                int i = [((NSString*) value) intValue];
                if(count==0) disableDeadzones[0] = i;   if(count==1) disableDeadzones[1] = i;
                if(count==2) disableDeadzones[2] = i;   if(count==3) disableDeadzones[3] = i;
                
                if(count==4) disable_l_analog[0] = i;   if(count==5) disable_l_analog[1] = i;
                if(count==6) disable_l_analog[2] = i;   if(count==7) disable_l_analog[3] = i;
                if(count==8) disable_r_analog[0] = i;   if(count==9) disable_r_analog[1] = i;
                if(count==10) disable_r_analog[2] = i;  if(count==11) disable_r_analog[3] = i;
                
                if(count==12) disableSticks[0] = i;     if(count==13) disableSticks[1] = i;
                if(count==14) disableSticks[2] = i;     if(count==15) disableSticks[3] = i;
                count++;
            }
        }
    }
    
    if (!standardUserDefaults) {  /* userDefault file or keys don't exist*/
        ViewController * viewcontroller = ((ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController);
        [viewcontroller.functions addStringtoLog:@"  No controller calibrations found, using defaults.\n"];
        [Calibration loadDefaultCalibrations];
        [Calibration saveControllerCalibrations];
    }
}


+ (void) saveControllerCalibrations {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *values1;
    NSString *values2;
    NSString *values3;
    NSString *values4;
    NSString *values5;
    NSString *values6;
    NSString *combinedValues;
    
    if (standardUserDefaults) {
        values1 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_max_x[0], stick_max_x[1], stick_max_x[2], stick_max_x[3]];
        values2 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_middle_x[0], stick_middle_x[1], stick_middle_x[2], stick_middle_x[3]];
        values3 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_max_y[0], stick_max_y[1], stick_max_y[2], stick_max_y[3]];
        values4 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_middle_y[0], stick_middle_y[1], stick_middle_y[2], stick_middle_y[3]];
        combinedValues = [NSString stringWithFormat:@"%@.%@.%@.%@", values1, values2, values3, values4];
        [standardUserDefaults setObject:combinedValues forKey:@"stick_calibration"];
        
        
        values1 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_max_x[0], c_stick_max_x[1], c_stick_max_x[2], c_stick_max_x[3]];
        values2 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_middle_x[0], c_stick_middle_x[1], c_stick_middle_x[2], c_stick_middle_x[3]];
        values3 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_max_y[0], c_stick_max_y[1], c_stick_max_y[2], c_stick_max_y[3]];
        values4 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_middle_y[0], c_stick_middle_y[1], c_stick_middle_y[2], c_stick_middle_y[3]];
        combinedValues = [NSString stringWithFormat:@"%@.%@.%@.%@", values1, values2, values3, values4];
        [standardUserDefaults setObject:combinedValues forKey:@"c_stick_calibration"];
        
        
        values1 = [NSString stringWithFormat:@"%i.%i.%i.%i", r_max[0], r_max[1], r_max[2], r_max[3]];
        values2 = [NSString stringWithFormat:@"%i.%i.%i.%i", r_middle[0], r_middle[1], r_middle[2], r_middle[3]];
        values3 = [NSString stringWithFormat:@"%i.%i.%i.%i", l_max[0], l_max[1], l_max[2], l_max[3]];
        values4 = [NSString stringWithFormat:@"%i.%i.%i.%i", l_middle[0], l_middle[1], l_middle[2], l_middle[3]];
        combinedValues = [NSString stringWithFormat:@"%@.%@.%@.%@", values1, values2, values3, values4];
        [standardUserDefaults setObject:combinedValues forKey:@"l_and_r_calibration"];
        
        
        values1 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_deadzone_x[0], stick_deadzone_x[1], stick_deadzone_x[2], stick_deadzone_x[3]];
        values2 = [NSString stringWithFormat:@"%i.%i.%i.%i", stick_deadzone_y[0], stick_deadzone_y[1], stick_deadzone_y[2], stick_deadzone_y[3]];
        values3 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_deadzone_x[0], c_stick_deadzone_x[1], c_stick_deadzone_x[2], c_stick_deadzone_x[3]];
        values4 = [NSString stringWithFormat:@"%i.%i.%i.%i", c_stick_deadzone_y[0], c_stick_deadzone_y[1], c_stick_deadzone_y[2], c_stick_deadzone_y[3]];
        values5 = [NSString stringWithFormat:@"%i.%i.%i.%i", l_deadzone[0], l_deadzone[1], l_deadzone[2], l_deadzone[3]];
        values6 = [NSString stringWithFormat:@"%i.%i.%i.%i", r_deadzone[0], r_deadzone[1], r_deadzone[2], r_deadzone[3]];
        combinedValues = [NSString stringWithFormat:@"%@.%@.%@.%@.%@.%@", values1, values2, values3, values4, values5, values6];
        [standardUserDefaults setObject:combinedValues forKey:@"deadzones"];
        
        
        values1 = [NSString stringWithFormat:@"%i.%i.%i.%i", disableDeadzones[0], disableDeadzones[1], disableDeadzones[2], disableDeadzones[3]];
        values2 = [NSString stringWithFormat:@"%i.%i.%i.%i", disable_l_analog[0], disable_l_analog[1], disable_l_analog[2], disable_l_analog[3]];
        values3 = [NSString stringWithFormat:@"%i.%i.%i.%i", disable_r_analog[0], disable_r_analog[1], disable_r_analog[2], disable_r_analog[3]];
        values4 = [NSString stringWithFormat:@"%i.%i.%i.%i", disableSticks[0], disableSticks[1], disableSticks[2], disableSticks[3]];
        combinedValues = [NSString stringWithFormat:@"%@.%@.%@.%@", values1, values2, values3, values4];
        [standardUserDefaults setObject:combinedValues forKey:@"controller_options"];
        
        
        [standardUserDefaults synchronize];
    }
}


+ (void) loadDefaultCalibrations {
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
        
        disable_l_analog[i] = false;
        disable_r_analog[i] = false;
        disableDeadzones[i] = false;
        disableSticks[i] = false;
    }
}


+ (void) restoreDefaultCalibrations {
    /* reset defaults */
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
    
    /* load defaults */
    [Calibration loadDefaultCalibrations];
    [Calibration saveControllerCalibrations];
}



+ (void) setCalibration:(int) port state:(int) i {
    calibrationState[port] = i;
}


+ (void) fillOptionsView:(OptionsViewController *) view {
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
    
    [self setDeadzoneTextFieldStates: view];
}


+ (void) setDeadzoneTextFieldStates:(OptionsViewController *) view {
    int p = view.currentPort;
    view.deadzoneX.enabled = !disableDeadzones[p];
    view.deadzoneY.enabled = !disableDeadzones[p];
    view.cdeadzoneX.enabled = !disableDeadzones[p];
    view.cdeadzoneY.enabled = !disableDeadzones[p];
    view.deadzoneL.enabled = !disableDeadzones[p];
    view.deadzoneR.enabled = !disableDeadzones[p];
}


+ (void) loadFromOptionsView:(OptionsViewController *) view {
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


@end


