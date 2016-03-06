//
//  Functions.m
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 21-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import "Functions.h"
#import <Foundation/Foundation.h>
#import "AdapterHandler.h"
#import "ViewController.h"

@implementation Functions

//@synthesize viewController;
@synthesize logString;

- (void) addStringtoLog: (NSString*) string {
    NSString *currentString = logString;
    if (currentString == NULL) {
        currentString = @"";
    }
    logString = [NSString stringWithFormat: @"%@%@", currentString, string];
    
    ViewController *viewController2 = (ViewController *) [[NSApplication sharedApplication] mainWindow].contentViewController;
    [viewController2.largeTextView setString:logString];
    //[viewController.largeTextView setString:logString];

}


- (void) initalizeAdapter {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[[GccManager alloc] init] setup];
    });

}

- (void) startDriver {
    printf("starting driver");
    [self addStringtoLog: @"starting driver\n"];
}

- (void) stopDriver {
    printf("stopping driver");
}

@end