//
//  CalibrateViewController.m
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 12-03-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import "CalibrateViewController.h"

@interface CalibrateViewController ()
@end


@implementation CalibrateViewController
@synthesize functions;
@synthesize currentController;

- (void)viewDidLoad {
    [super viewDidLoad];
    ViewController *mainViewController =  (ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController;
    functions = mainViewController.functions;
    currentController = functions.currentCalibration;
    
    NSString *string = [NSString stringWithFormat:@"Calibrating Port %i", currentController + 1];
    [self setTitle: string];
}

- (void) fillInTextBoxes {
    
}



- (IBAction)closeButton:(NSButton *)sender {
    [self dismissViewController:self];
}

@end
