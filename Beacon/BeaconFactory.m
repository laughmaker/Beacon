//
//  BeaconFactory.m
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import "BeaconFactory.h"
#import "BeaconClientBluetooth.h"
#import "BeaconClientSystem.h"
#import "BeaconServerBluetooth.h"
#import "BeaconServerSystem.h"

#define TargetOSVersion ([[UIDevice currentDevice].systemVersion doubleValue])

@implementation BeaconFactory

+ (BeaconClient*)beaconClient
{
    return [[BeaconClientSystem alloc] init];
    if (7.0 > TargetOSVersion) {
        return [[BeaconClientBluetooth alloc] init];
    }
    else {
        return [[BeaconClientSystem alloc] init];
    }
}

+ (BeaconServer*)beaconServer
{
    return [[BeaconServerSystem alloc] init];;
    if (7.0 > TargetOSVersion) {
        return [[BeaconServerBluetooth alloc] init];
    }
    else {
        return [[BeaconServerSystem alloc] init];
    }
}
@end
