//
//  ViewController.h
//  WiiU GC Adapter
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Functions.h"
#import "AdapterHandler.h"


@class Functions;

@interface ViewController : NSViewController

@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (strong, nonatomic) IBOutlet NSTextField *TextField;

@property (strong, nonatomic) IBOutlet NSTextView *largeTextView;

@property (weak) IBOutlet NSButtonCell *startButton;
@property (weak) IBOutlet NSButtonCell *stopButton;
@property (weak) IBOutlet NSButtonCell *initializeAdapterButton;


@property NSString *string;
@property Functions *functions;

@end

