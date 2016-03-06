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


@interface ViewController : NSViewController


@property (weak) IBOutlet NSProgressIndicator *ProgressBar;
@property (strong, nonatomic) IBOutlet NSTextField *TextField;

@property (unsafe_unretained) IBOutlet NSTextView *largeTextView;

@property NSString *string;
@property Functions *functies;

@end

