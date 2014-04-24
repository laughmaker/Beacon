//
//  ViewController.h
//  IBeaconMonitorTest
//
//  Created by ediv on 14-2-13.
//  Copyright (c) 2014年 ediv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BeaconClient.h"

@interface ViewController : UIViewController<BeaconClientProtocol>

@end
