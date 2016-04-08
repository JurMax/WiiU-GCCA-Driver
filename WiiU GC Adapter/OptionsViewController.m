//
//  CalibrateViewController.m
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 12-03-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()
@end


@implementation OptionsViewController
@synthesize functions;
@synthesize currentPort;
@synthesize advancedOptions;

@synthesize calibrateControllerButton;
@synthesize restoreDefaultsButton;
@synthesize nextButton;
@synthesize instructionsTextField;
@synthesize disclosureButton;


NSString *calibratingInstructions[] = { @"",
        @"Don't touch any of the triggers or the analog sticks on the controller, then press next.",
        @"Slowly spin the main stick around a few times. Then press next.",
        @"Slowly spin the c-stick around a few times. Then press next.",
        @"Fully press the L and R triggers a few times. Then press next.",
        @"The calibration is finished!"
    };
short int currentLabel = 0;

ViewController *mainViewController;


- (void) viewDidLoad {
    [super viewDidLoad];
    
    mainViewController =  (ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController;
    [mainViewController.functions setOptionsViewController:self];

    functions = mainViewController.functions;
    currentPort = functions.currentPortSettings;
    currentLabel = 0;
    
    NSString *string = [NSString stringWithFormat:@"Port %i Options", currentPort + 1];
    [self setTitle: string];
    
    [functions.gccManager fillOptionsView: self];
    
    advancedOptions = !mainViewController.advancedSettings.state;
    disclosureButton.state = advancedOptions;
    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (!self.isViewLoaded) {}
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setWindowSize: NO];
        });
    });
}


- (IBAction)calibrateButton:(NSButton *)sender {
    NSLog(@"calibrating port %i\n", [functions currentPortSettings]);
    
    currentLabel = 1;
    [self setInstructionLabel];
    
    calibrateControllerButton.enabled = FALSE;
    restoreDefaultsButton.enabled = FALSE;
    nextButton.enabled = TRUE;
}

- (IBAction)calibrateNext:(NSButton *)sender {
    currentLabel += 1;
    [self setInstructionLabel];
    
    if (currentLabel >= 5) {
        calibrateControllerButton.enabled = TRUE;
        restoreDefaultsButton.enabled = TRUE;
        nextButton.enabled = FALSE;
    }
}

- (IBAction)loadDefaultsButton:(NSButton *)sender {
    [[functions gccManager] loadDefaultCalibrations];
    [[functions gccManager] fillOptionsView:self];
}


- (IBAction)valueChanged:(NSTextField *)sender {
    NSString *string = [NSString stringWithFormat:@"%i", [sender intValue]];
    if ([sender intValue] < 0)  /* make positive */
        string = [string substringFromIndex:1];
    
    [sender setStringValue: string];
    [[functions gccManager] loadFromOptionsView:self];
}


- (IBAction)disclosureButton:(NSButton *)sender {
    advancedOptions = sender.state;
    [self setWindowSize: YES];
    mainViewController.advancedSettings.state = !advancedOptions;
}


- (IBAction)checkBoxOptions:(NSButton *)sender {
    [[functions gccManager] loadFromOptionsView:self];
}


- (void) setWindowSize:(bool) animation {
    NSRect frame = [[[self view] window] frame];
    int height;
    if (advancedOptions) {
        height = 298;
    } else {
        height = 164;
    }
    frame.origin.y += frame.size.height;
    frame.origin.y -= height;
    frame.size.height = height;
    
    [[[self view] window] setFrame: frame display: YES animate: animation];
}


- (void) setInstructionLabel {
    [functions.gccManager setCalibration: currentPort : currentLabel];
    [[functions gccManager] fillOptionsView:self];

    NSString *string = calibratingInstructions[currentLabel];
    if (string == nil) {
        string = @"- error: string not found.- ";
    }
    //TODO instructions do something.
    instructionsTextField.stringValue = string;
}

@end
