//
//  CalibrateViewController.m
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 12-03-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import "OptionsViewController.h"


@implementation OptionsViewController

@synthesize mainViewController;
@synthesize functions;

@synthesize currentPort;
@synthesize advancedOptions;
@synthesize currentInstructionLabel;

@synthesize calibrateControllerButton;
@synthesize restoreDefaultsButton;
@synthesize nextButton;
@synthesize instructionsTextField;
@synthesize disclosureButton;


NSString *const calibratingInstructions[] = { @"",
        @"Don't touch any of the triggers or the analog sticks on the controller, then press next.",
        @"Slowly spin the main stick around a few times. Then press next.",
        @"Slowly spin the c-stick around a few times. Then press next.",
        @"Fully press the L and R triggers a few times. Then press next.",
        @"The calibration is finished!"
    };


- (void) viewDidLoad {
    [super viewDidLoad];
    
    mainViewController = (ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController;
    [mainViewController.functions setOptionsViewController:self];
    functions = mainViewController.functions;
    
    currentPort = functions.currentPortSettings;
    advancedOptions = !mainViewController.advancedSettings.state;
    disclosureButton.state = advancedOptions;
    currentInstructionLabel = 0;
    
    NSString *viewTitle = [NSString stringWithFormat:@"Port %i Options", currentPort + 1];
    [self setTitle: viewTitle];
    
    
    [Calibration fillOptionsView: self];
    
    
    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        while (!self.isViewLoaded) {}  /* wait untill the view is loaded */
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setWindowSize: NO];
        });
    });
    
}


- (IBAction) calibrateButton:(NSButton *) sender {
    NSLog(@"calibrating port %i\n", [functions currentPortSettings]);
    
    currentInstructionLabel = 1;
    [self setInstructionLabel];
    
    calibrateControllerButton.enabled = FALSE;
    restoreDefaultsButton.enabled = FALSE;
    nextButton.enabled = TRUE;
}

- (IBAction) calibrateNext:(NSButton *) sender {
    currentInstructionLabel += 1;
    [self setInstructionLabel];
    
    if (currentInstructionLabel >= 5) {  /* calibration has finished */
        calibrateControllerButton.enabled = TRUE;
        restoreDefaultsButton.enabled = TRUE;
        nextButton.enabled = FALSE;
    }
}

- (IBAction) loadDefaultsButton:(NSButton *) sender {
    [Calibration loadDefaultCalibrations];
    [Calibration fillOptionsView:self];
}


- (IBAction) valueChanged:(NSTextField *) sender {
    NSString *str = [NSString stringWithFormat:@"%i", [sender intValue]];
    
    if ([sender intValue] < 0) {  /* make positive by removing - */
        str = [str substringFromIndex:1];
    }
    
    [sender setStringValue: str];
    [Calibration loadFromOptionsView:self];
}


- (IBAction) disclosureButton:(NSButton *) sender {
    advancedOptions = sender.state;
    mainViewController.advancedSettings.state = !advancedOptions;
    [self setWindowSize: YES];
}


- (IBAction) checkBoxOptions:(NSButton *) sender {
    [Calibration loadFromOptionsView: self];
    [Calibration setDeadzoneTextFieldStates: self];
}


- (void) setWindowSize:(bool) withAnimation {
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
    
    [[[self view] window] setFrame:frame display:YES animate:withAnimation];
}


- (void) setInstructionLabel {
    [Calibration setCalibration:currentPort state:currentInstructionLabel];
    [Calibration fillOptionsView:self];

    NSString *str = calibratingInstructions[currentInstructionLabel];
    if (str == nil) {
        str = @"- error: string not found.- ";
    }
    
    instructionsTextField.stringValue = str;
}


@end


