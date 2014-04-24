//
//  BeaconClient.h
//  BeaconEmulator
//
//  Created by ediv on 14-3-26.
//
//

#import <Foundation/Foundation.h>

@protocol BeaconClientProtocol;

@interface BeaconClient : NSObject

@property (nonatomic, strong) NSString* uuid;
@property (nonatomic, strong) NSNumber* major;
@property (nonatomic, strong) NSNumber* minor;

@property (nonatomic, weak) id<BeaconClientProtocol> delegate;

+ (BeaconClient*)beaconClient;
- (void)startScan;
- (void)stopScan;

@end

@protocol BeaconClientProtocol <NSObject>

- (void)beaconClientDidStartScan:(BeaconClient*)client;
- (void)beaconClient:(BeaconClient*)client didFailToStartScan:(NSError*)error;

- (void)beaconClientDidStopScan:(BeaconClient*)client;
- (void)beaconClient:(BeaconClient*)client didFailToStopScan:(NSError*)error;

- (void)beaconClient:(BeaconClient*)client didDiscover:(NSArray*)notes;

@end
