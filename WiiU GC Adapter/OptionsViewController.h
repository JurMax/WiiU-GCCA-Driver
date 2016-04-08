//
//  CalibrateViewController.h
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 12-03-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Functions.h"

@class Functions;

@interface OptionsViewController : NSViewController

- (IBAction)calibrateButton:(NSButton *)sender;
- (IBAction)loadDefaultsButton:(NSButton *)sender;
- (IBAction)valueChanged:(NSTextField *)sender;
- (IBAction)disclosureButton:(NSButton *)sender;
- (IBAction)checkBoxOptions:(NSButton *)sender;

- (void) setWindowSize:(bool) animation;
- (void) setInstructionLabel;

@property (weak) IBOutlet NSTextField *instructionsTextField;
@property (weak) IBOutlet NSButton *calibrateControllerButton;
@property (weak) IBOutlet NSButton *restoreDefaultsButton;
@property (weak) IBOutlet NSButton *nextButton;

@property (weak) IBOutlet NSButton *disableLeftAnalog;
@property (weak) IBOutlet NSButton *disableRightAnalog;
@property (weak) IBOutlet NSButton *disableDeadzones;
@property (weak) IBOutlet NSButton *disableTriggers;

@property (weak) IBOutlet NSButton *disclosureButton;

@property (weak) IBOutlet NSTextField *stickXMiddle;
@property (weak) IBOutlet NSTextField *stickXHigh;
@property (weak) IBOutlet NSTextField *stickYMiddle;
@property (weak) IBOutlet NSTextField *stickYHigh;

@property (weak) IBOutlet NSTextField *cstickXMiddle;
@property (weak) IBOutlet NSTextField *cstickXHigh;
@property (weak) IBOutlet NSTextField *cstickYMiddle;
@property (weak) IBOutlet NSTextField *cstickYHigh;

@property (weak) IBOutlet NSTextField *l_Middle;
@property (weak) IBOutlet NSTextField *l_High;
@property (weak) IBOutlet NSTextField *r_Middle;
@property (weak) IBOutlet NSTextField *r_High;

@property (weak) IBOutlet NSTextField *deadzoneX;
@property (weak) IBOutlet NSTextField *deadzoneY;
@property (weak) IBOutlet NSTextField *cdeadzoneX;
@property (weak) IBOutlet NSTextField *cdeadzoneY;
@property (weak) IBOutlet NSTextField *deadzoneL;
@property (weak) IBOutlet NSTextField *deadzoneR;


@property Functions *functions;
@property int currentPort;
@property bool advancedOptions;

@end
