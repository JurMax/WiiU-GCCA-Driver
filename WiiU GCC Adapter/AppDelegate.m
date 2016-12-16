//
//  AppDelegate.m
//  WiiU GC Adapter
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 JurMax. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize mainWindow;
@synthesize statusItem;
@synthesize statusBarMenu;


- (void) applicationDidFinishLaunching:(NSNotification *) aNotification {

    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.image = [NSImage imageNamed:@"menu_icon.png"];
    [statusItem.image setTemplate:YES];
    [statusItem setMenu: statusBarMenu];
    
    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        bool isMainWindowLoaded = false;
        
        while (!isMainWindowLoaded) {
            if ([[NSApplication sharedApplication] mainWindow] != nil) {
                
                isMainWindowLoaded = true;
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    mainWindow = [[NSApplication sharedApplication] mainWindow];
                    [mainWindow setReleasedWhenClosed:NO];
                    [mainWindow setMenu: statusBarMenu];
                    
                    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
                    [viewController.functions validateCalibrateButtons];
                });
            }
        }
    });
}


- (BOOL) validateMenuItem:(NSMenuItem *) item {
    
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    
    if (item.tag == 7) {  /* open or close window */
        if (mainWindow.isVisible) {
            item.title = @"Close Window";
        }
        else {
            item.title = @"Open Window";
        }
        
        return true;
    }
    else if ([item.title isEqual: @"Start"]) {
        return viewController.startButton.enabled;
    }
    else if ([item.title isEqual: @"Stop"]) {
        return viewController.stopButton.enabled;
    }
    
    else if ([item.title isEqual: @"Port 1"]) {
        return [viewController.functions.gccManager isControllerInserted: 0];
    }
    else if ([item.title isEqual: @"Port 2"]) {
        return [viewController.functions.gccManager isControllerInserted: 1];
    }
    else if ([item.title isEqual: @"Port 3"]) {
        return [viewController.functions.gccManager isControllerInserted: 2];
    }
    else if ([item.title isEqual: @"Port 4"]) {
        return [viewController.functions.gccManager isControllerInserted: 3];
    }
    
    return true;
}



- (IBAction) InitializeAdapter:(id) sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functions initializeAdapter: false];
}


- (IBAction) startDriver:(id) sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functions startDriver];
}


- (IBAction) stopDriver:(id) sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functions stopDriver];
}


- (IBAction) quitApplication:(id) sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functions addStringtoLog:@"Quiting..."];
    
    [Calibration saveControllerCalibrations];
    [viewController.functions stopDriver];
    [viewController.functions.gccManager reset];
    
    exit(0);
}


- (IBAction) openOrCloseWindow:(NSMenuItem *) sender {
    if (mainWindow.isVisible) {
        [mainWindow close];
    }
    else {
        [mainWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
}


- (IBAction) calibrateButtons:(NSMenuItem *) sender {
    if (!mainWindow.isVisible) {
        [mainWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
    
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    
    viewController.functions.advancedSettings = !viewController.advancedSettings.state;
    viewController.functions.currentPortSettings = (int) (sender.tag - 1);
    [viewController performSegueWithIdentifier:@"optionsSegue" sender:self];
}


@end


