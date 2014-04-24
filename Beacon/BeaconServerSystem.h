//
//  BeaconServerSystem.h
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import "BeaconServer.h"

@interface BeaconServerSystem : BeaconServer

- (void)startAdvertising;
- (void)stopAdvertising;

@end
