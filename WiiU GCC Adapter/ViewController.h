//
//  ViewController.h
//  WiiU GC Adapter
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Functions.h"


@class Functions;


@interface ViewController : NSViewController

@property Functions *functions;

@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (strong) IBOutlet NSTextView *largeTextView;

@property (weak) IBOutlet NSButtonCell *startButton;
@property (weak) IBOutlet NSButtonCell *stopButton;
@property (weak) IBOutlet NSButtonCell *initializeAdapterButton;
@property (weak) IBOutlet NSButton *advancedSettings;

@property (weak) IBOutlet NSButton *calibrateButton1;
@property (weak) IBOutlet NSButton *calibrateButton2;
@property (weak) IBOutlet NSButton *calibrateButton3;
@property (weak) IBOutlet NSButton *calibrateButton4;

@end


