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

@property (strong, nonatomic) IBOutlet NSTextView *textCircle;

@property (strong, nonatomic) IBOutlet NSTextView *stickRoundText;
@property (weak) IBOutlet NSButton *stickButton;
@property (strong, nonatomic) IBOutlet NSTextView *cstickRoundText;

@property (weak) IBOutlet NSTextField *text;

@property Functions *functions;
@property int currentPort;

@end
