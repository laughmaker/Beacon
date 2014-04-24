//
//  BeaconClient.m
//  BeaconEmulator
//
//  Created by ediv on 14-3-26.
//
//

#import "BeaconClient.h"
#import "BeaconFactory.h"

@implementation BeaconClient

#pragma mark - public methods

+ (BeaconClient*)beaconClient
{
    return [BeaconFactory beaconClient];
}

- (void)startScan
{
    
}

- (void)stopScan
{
    
}

@end
