//
//  AppDelegate.h
//  IBeaconAdvertiseTest
//
//  Created by ediv on 14-2-13.
//  Copyright (c) 2014年 ediv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconServer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BeaconServerProtocol>
{
    BeaconServer* _server;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDictionary* beaconPeripheralData;
@end
