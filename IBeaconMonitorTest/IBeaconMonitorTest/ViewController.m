//
//  ViewController.m
//  IBeaconMonitorTest
//
//  Created by ediv on 14-2-13.
//  Copyright (c) 2014年 ediv. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UILabel* _label;
    BeaconClient* _client;
}
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _client = [BeaconClient beaconClient];
    _client.delegate = self;
    _client.uuid = @"45C7447D-BD46-4EC1-AB4F-EA5448D069D6";
//    _client.major = @(11);
//    _client.minor = @(20);
    
    [_client startScan];
}

- (void)loadView
{
    [super loadView];
    
    _label = [[UILabel alloc] initWithFrame:self.view.bounds];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor blackColor];
    _label.font = [UIFont systemFontOfSize:21];
    
    [self.view addSubview:_label];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - beacon client delegate

- (void)beaconClientDidStartScan:(BeaconClient *)client
{
    NSLog(@"beaconClientDidStartScan");
}

- (void)beaconClientDidStopScan:(BeaconClient *)client
{
    NSLog(@"beaconClientDidStopScan");
}

- (void)beaconClient:(BeaconClient *)client didFailToStartScan:(NSError *)error
{
    NSLog(@"didFailToStartScan");
}

- (void)beaconClient:(BeaconClient *)client didFailToStopScan:(NSError *)error
{
    NSLog(@"didFailToStopScan");
}

- (void)beaconClient:(BeaconClient *)client didDiscover:(NSArray *)notes
{
    NSLog(@"didDiscover");
    
    for (NSDictionary* tmp in notes) {
        NSLog(@"%@", tmp);
    }
}

@end
