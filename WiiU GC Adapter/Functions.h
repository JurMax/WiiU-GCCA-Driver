//
//  Functions.h
//  wiiu-gcc-adapter-bin
//
//  Created by Jurriaan van den Berg on 21-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface Functions : NSObject

//@property (strong) ViewController* viewController;
@property (strong, nonatomic) NSString* logString;


- (void) addStringtoLog: (NSString*) string;
- (void) initalizeAdapter;
- (void) startDriver;
- (void) stopDriver;

@end
