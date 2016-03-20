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

- (void) viewDidLoad {
    [super viewDidLoad];

    ViewController *mainViewController =  (ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController;

    functions = mainViewController.functions;
    currentPort = functions.currentPortSettings;
    
    NSString *string = [NSString stringWithFormat:@"Port %i Options", currentPort + 1];
    [self setTitle: string];

    
    [functions.gccManager fillOptionsView: self];

    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (_stickRoundText.layer.cornerRadius != 30 || _cstickRoundText.layer.cornerRadius != 25 || TRUE) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _stickRoundText.layer.cornerRadius = 30;
                _cstickRoundText.layer.cornerRadius = 25;
                //printf("%f\n", _stickRoundText.layer.cornerRadius);
            });
        }
    });
}


- (IBAction) closeButton:(NSButton *) sender {
    [self dismissViewController: self];
}


- (IBAction) valueChanged:(NSTextField *) sender {
    printf("int: %i\n", [sender intValue]);
    NSString *string = [NSString stringWithFormat:@"%i", [sender intValue]];
    [sender setStringValue: string];
    //sender.stringValue;
}

- (IBAction)test:(NSButtonCell *)sender {
    NSPoint frame =_text.frame.origin;
    frame.x += 5;
    [_text setFrameOrigin:frame];
    //[_stickRoundText setString: string];
    //_stickRoundText.layer.cornerRadius = 30;
}


@end
