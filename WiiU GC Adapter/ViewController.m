//
//  ViewController.m
//  WiiU GC Adapter
//
//  Created by Jurriaan van den Berg on 20-02-16.
//  Copyright © 2016 Mitch Dzugan. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

//Functions *functies;
@synthesize functies;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    functies = [[Functions alloc] init];
    //functies.viewController = self;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    printf("updateview");
    // Update the view, if already loaded.
}


- (IBAction)initializeAdapter:(NSButton *)sender {
    [functies initalizeAdapter];
}

- (IBAction)startDriver:(NSButton *)sender {
    /*
    [_largeTextView setString:@"testttestt\nestt\nestt\nestt\nesadsfasdgadsgasdgadfhadfgdsafasdfasdgasdfadsasdgasdgadsgkljasdflkahsdfkjhasdkfjhasdkjfhzxkjhfkasdtt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\nestt\ntest"];*/
    [functies startDriver];
}

- (IBAction)stopDriver:(NSButton *)sender {
    [functies stopDriver];
}






- (IBAction)waitFunction:(NSTextField *)sender {
    [[[GccManager alloc] init] testVoid: sender progressbar:_ProgressBar];
}



@end
