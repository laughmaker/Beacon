//
//  BeaconServerSystem.m
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import "BeaconServerSystem.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "BeaconConstant.h"

@interface BeaconServerSystem () <CBPeripheralManagerDelegate>
{
    CBPeripheralManager* _manager;
    CLBeaconRegion* _region;
}
@end

@implementation BeaconServerSystem

#pragma mark - public methods

- (void)startAdvertising
{
    [super startAdvertising];
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] || nil != _manager || nil != _region) {
        [self failedToStartAdvertise];
        return;
    }
    
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)stopAdvertising
{
    [super stopAdvertising];
    [_manager stopAdvertising];
    _region = nil;
}

#pragma mark - private methods

- (void)successToStartAdvertise
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(beaconServerDidStartAdvertise:)]) {
        [self.delegate beaconServerDidStartAdvertise:self];
    }
}

- (void)successToStopAdvertise
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(beaconServerDidStopAdvertise:)]) {
        [self.delegate beaconServerDidStopAdvertise:self];
    }
}

- (void)failedToStartAdvertise
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(beaconServer:didFailToStartAdvertise:)]) {
        [self.delegate beaconServer:self didFailToStartAdvertise:[[NSError alloc] initWithDomain:@"advertise error" code:9002 userInfo:nil]];
    }
}

#pragma mark - peripheral manager delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBCentralManagerStatePoweredOn:
        {
            CLBeaconRegion* region = nil;
            if (nil == self.major || nil == self.minor) {
                region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.uuid] identifier:IdentifierForIBeacon];
            }
            else {
                region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.uuid] major:[self.major unsignedShortValue] minor:[self.minor unsignedShortValue] identifier:IdentifierForIBeacon];
            }
            
            NSDictionary* peripheralInfo = [region peripheralDataWithMeasuredPower:nil];
            [_manager startAdvertising:peripheralInfo];
        }
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
        [self failedToStartAdvertise];
        return ;
    }
    
    [self successToStartAdvertise];
}

@end
