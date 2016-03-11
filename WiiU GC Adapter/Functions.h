//
//  Functions.h
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 21-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AdapterHandler.h"
#import "ViewController.h"

@class GccManager;
@class ViewController;

@interface Functions : NSObject

@property (nonatomic) bool isInitialized;
@property (nonatomic) bool isDriverRunning;
@property (nonatomic) long int driverRunningTime;
@property (strong, nonatomic) NSString* logString;
@property (nonatomic) GccManager* gccManager;


- (void) addStringtoLog: (NSString*) string;
- (void) initializeAdapterOnly;
- (void) initializeAdapter;
- (void) startDriver;
- (void) stopDriver;
- (void) startProgressBar: (float) seconds;
- (ViewController*) getViewController;
@end
