//
//  BeaconClientSystem.m
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import "BeaconClientSystem.h"
#import <CoreLocation/CoreLocation.h>
#import "BeaconConstant.h"

@interface BeaconClientSystem () <CLLocationManagerDelegate>
{
    CLLocationManager* _manager;
    CLBeaconRegion* _region;
    BOOL _isStartRangeBeacon;
}
@end

@implementation BeaconClientSystem

- (id)init
{
    self = [super init];
    
    if (self) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
    }
    
    return self;
}

#pragma mark - public methods

- (void)startScan
{
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] || nil != _region) {
        [self failedToStartScan];
        return;
    }
    
    CLBeaconRegion* region = nil;
    if (nil == self.major || nil == self.minor) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.uuid] identifier:IdentifierForIBeacon];
    }
    else {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.uuid] major:[self.major unsignedShortValue] minor:[self.minor unsignedShortValue] identifier:IdentifierForIBeacon];
    }

    [_manager startMonitoringForRegion:region];
    _region = region;
}

- (void)stopScan
{
    if (nil == _region) {
        return;
    }
    
    [_manager stopMonitoringForRegion:_region];
    [self successToStopScan];
}

#pragma mark - private methods

- (void)successToStartScan
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(beaconClientDidStartScan:)]) {
        [self.delegate beaconClientDidStartScan:self];
    }
}

- (void)failedToStartScan
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(beaconClient:didFailToStartScan:)]) {
        [self.delegate beaconClient:self didFailToStartScan:[[NSError alloc] initWithDomain:@"not support!" code:9001 userInfo:nil]];
    }
}

- (void)successToStopScan
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(beaconClientDidStopScan:)]) {
        [self.delegate beaconClientDidStopScan:self];
    }
}

- (void)successToDiscover:(NSArray*)param
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(beaconClient:didDiscover:)]) {
        [self.delegate beaconClient:self didDiscover:param];
    }
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (CLRegionStateInside == state && !_isStartRangeBeacon) {
        [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        _isStartRangeBeacon = YES;
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:@"Beacon didDetermineState!"];
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSMutableArray* notes = [[NSMutableArray alloc] init];
    
    for (CLBeacon* beacon in beacons) {
        if (nil == beacon.major || nil == beacon.minor) {
            continue;
        }
        
        [notes addObject:@{@"major" : beacon.major, @"minor" : beacon.minor}];
    }
    
    [self successToDiscover:notes];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    _region = nil;
    [self failedToStartScan];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if (!_isStartRangeBeacon) {
        [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        _isStartRangeBeacon = YES;
        
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:@"Beacon enter Region!"];
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if (_isStartRangeBeacon) {
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        _isStartRangeBeacon = NO;
        
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:@"Beacon leave Region!"];
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    _region = nil;
    [self failedToStartScan];
}

@end
