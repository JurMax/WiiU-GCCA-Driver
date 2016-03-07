//
//  AppDelegate.m
//  WiiU GC Adapter
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import "AppDelegate.h"
#import "Functions.h"
#import "ViewController.h"


@interface AppDelegate ()
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;
@property (weak) IBOutlet NSMenu *StatusBarMenu;
@property (weak) IBOutlet NSWindow *mainWindow;
@end


@implementation AppDelegate
@synthesize mainWindow;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // nsrover.wordpress.com/2014/10/10/creating-a-os-x-menubar-only-app/
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"switchIcon.png"];
    [_statusItem.image setTemplate:YES];
    [_statusItem setMenu: _StatusBarMenu];
    
    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        bool isMainWindowLoaded = false;
        while (!isMainWindowLoaded) {
            if ([[NSApplication sharedApplication] mainWindow] != nil) {
                isMainWindowLoaded = true;
                dispatch_async(dispatch_get_main_queue(), ^{
                    mainWindow = [[NSApplication sharedApplication] mainWindow];
                    [mainWindow setReleasedWhenClosed:NO];
                    [mainWindow setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
                });
            }
        }
    });
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functions stopDriver];
    [viewController.functions.gccManager reset];

    NSLog(@"Quiting...");
}


- (BOOL)validateMenuItem:(NSMenuItem *)item {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    if (item.tag == 7) { /* open/close window*/
        if (mainWindow.isVisible) {
            item.title = @"Close Window";
        } else {
            item.title = @"Open Window";
        }
        return TRUE;
    }
    else if ([item.title isEqual: @"Start"]) {
        return viewController.startButton.enabled;
    }
    else if ([item.title isEqual: @"Stop"]) {
        return viewController.stopButton.enabled;
    }
    return TRUE;
}


//* Menu Items *//
- (IBAction)InitializeAdapter:(id)sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functions initializeAdapterOnly];
}

- (IBAction)startDriver:(id)sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functions startDriver];
}

- (IBAction)stopDriver:(id)sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functions stopDriver];
}

- (IBAction)quitApplication:(id)sender {
    exit(0);
}

- (IBAction)openOrCloseWindow:(NSMenuItem *)sender {
    if (mainWindow.isVisible) {
        [mainWindow close];
    } else {
        [mainWindow makeKeyAndOrderFront:nil];
    }
}



@end
