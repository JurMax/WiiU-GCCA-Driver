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

@interface CalibrateViewController : NSViewController

@property Functions *functions;
@property int currentController;

@end
