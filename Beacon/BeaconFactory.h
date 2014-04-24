//
//  BeaconFactory.h
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import <Foundation/Foundation.h>
#import "BeaconClient.h"
#import "BeaconServer.h"
@interface BeaconFactory : NSObject

+ (BeaconClient*)beaconClient;
+ (BeaconServer*)beaconServer;

@end
