//
//  BeaconClientBluetooth.h
//  BeaconEmulator
//
//  Created by ediv on 14-3-26.
//
//

#import "BeaconClient.h"

@interface BeaconClientBluetooth : BeaconClient

- (void)startScan;
- (void)stopScan;

@end
