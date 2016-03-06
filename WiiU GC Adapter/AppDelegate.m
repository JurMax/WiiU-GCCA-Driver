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
                mainWindow = [[NSApplication sharedApplication] mainWindow];
                [mainWindow setReleasedWhenClosed:NO];
            }
        }
    });
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}


- (BOOL)validateMenuItem:(NSMenuItem *)item {
    if ([item.title  isEqual: @"Open Window"]) {
        return !mainWindow.isVisible;
    }
    return TRUE;
}


//* Menu Items *//
- (IBAction)InitializeAdapter:(id)sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functies initalizeAdapter];
}

- (IBAction)startDriver:(id)sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functies startDriver];
}

- (IBAction)stopDriver:(id)sender {
    ViewController *viewController = (ViewController *) mainWindow.contentViewController;
    [viewController.functies stopDriver];
}

- (IBAction)quitApplication:(id)sender {
    exit(0);
}

- (IBAction)OpenWindow:(id)sender {
    [mainWindow makeKeyAndOrderFront:nil];
}



@end
