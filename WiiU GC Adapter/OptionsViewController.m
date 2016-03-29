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

ViewController *mainViewController;

- (void) viewDidLoad {
    [super viewDidLoad];

    mainViewController =  (ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController;

    functions = mainViewController.functions;
    currentPort = functions.currentPortSettings;
    
    NSString *string = [NSString stringWithFormat:@"Port %i Options", currentPort + 1];
    [self setTitle: string];
    
    [functions.gccManager fillOptionsView: self];
    
    
    advancedOptions = !mainViewController.advancedSettings.state;
    _disclosureButton.state = advancedOptions;
    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (!self.isViewLoaded) {}
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setWindowSize: NO];
        });
    });
}


- (IBAction)calibrateButton:(NSButton *)sender {
    NSLog(@"calibrating port %i\n", [functions currentPortSettings]);
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

@end
