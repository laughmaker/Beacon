//
//  BeaconServerBluetooth.h
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import "BeaconServer.h"

@interface BeaconServerBluetooth : BeaconServer

- (void)startAdvertising;
- (void)stopAdvertising;

@end
