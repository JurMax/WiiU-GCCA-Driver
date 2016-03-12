//
//  ViewController.m
//  WiiU GC Adapter
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController
@synthesize functions;

- (void)viewDidLoad {
    [super viewDidLoad];
    functions = [[Functions alloc] init];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


- (IBAction)initializeAdapter:(NSButton *)sender {
    [functions initializeAdapterOnly];
}

- (IBAction)startDriver:(NSButton *)sender {
    [functions startDriver];
}


- (IBAction)stopDriver:(NSButton *)sender {
    [functions stopDriver];
}

- (IBAction)clearLog:(NSButton *)sender {
    
    [functions setLogString: @""];
    [_largeTextView setString: @""];
    NSLog(@"Log: *Log cleared*");
}

- (IBAction)calibrateButtons:(NSButton *)sender {
    [functions calibrateControllers: (int) sender.tag];
}


@end
