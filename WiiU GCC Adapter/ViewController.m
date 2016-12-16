//
//  ViewController.m
//  WiiU GC Adapter
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

@synthesize functions;
@synthesize largeTextView;
@synthesize advancedSettings;


- (void) viewDidLoad {
    [super viewDidLoad];
    functions = [[Functions alloc] init];
    [functions setMainViewController:self];
}


- (void) setRepresentedObject:(id) representedObject {
    [super setRepresentedObject:representedObject];
}


- (IBAction) initializeAdapter:(NSButton *) sender {
    [functions initializeAdapter: false];
}


- (IBAction) startDriver:(NSButton *) sender {
    [functions startDriver];
}


- (IBAction) stopDriver:(NSButton *) sender {
    [functions stopDriver];
}


- (IBAction) clearLog:(NSButton *) sender {
    [functions setLogString: @""];
    [largeTextView setString: @""];
    NSLog(@"Log: *Log cleared*");
}


- (IBAction) openPortSettings:(NSButton *) sender {
    functions.advancedSettings = !advancedSettings.state;
    functions.currentPortSettings = (int) (sender.tag - 1);
    [self performSegueWithIdentifier:@"optionsSegue" sender:self];
}


@end


