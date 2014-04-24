//
//  BeaconServer.m
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import "BeaconServer.h"
#import "BeaconFactory.h"

@implementation BeaconServer

#pragma mark - public methods

+ (BeaconServer*)beaconServer
{
    return [BeaconFactory beaconServer];
}

- (void)startAdvertising
{
}

- (void)stopAdvertising
{
}


@end
