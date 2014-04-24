//
//  BeaconServer.h
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import <Foundation/Foundation.h>

@protocol BeaconServerProtocol;

@interface BeaconServer : NSObject
{
    @protected
    NSDictionary* _peripheralInfo;
}

@property (nonatomic, weak) id<BeaconServerProtocol> delegate;

@property (nonatomic, strong) NSString* uuid;
@property (nonatomic, strong) NSNumber* major;
@property (nonatomic, strong) NSNumber* minor;

+ (BeaconServer*)beaconServer;
- (void)startAdvertising;
- (void)stopAdvertising;

@end

@protocol BeaconServerProtocol <NSObject>

- (void)beaconServerDidStartAdvertise:(BeaconServer*)server;
- (void)beaconServerDidStopAdvertise:(BeaconServer*)server;

- (void)beaconServer:(BeaconServer*)server didFailToStartAdvertise:(NSError*)error;

@end
