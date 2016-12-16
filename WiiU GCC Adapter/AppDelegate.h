//
//  AppDelegate.h
//  WiiU GC Adapter
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Functions.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *mainWindow;

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;
@property (strong) IBOutlet NSMenu *statusBarMenu;

@end


