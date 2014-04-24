//
//  BeaconServerBluetooth.m
//  BeaconEmulator
//
//  Created by ediv on 14-3-27.
//
//

#import "BeaconServerBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BeaconServerBluetooth () <CBPeripheralManagerDelegate>
{
    CBPeripheralManager* _manager;
    CBService* _service;
}
@end

@implementation BeaconServerBluetooth

- (id)init
{
    self = [super init];
    if (self) {
        _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    
    return self;
}

#pragma mark - public methods

- (void)startAdvertising
{
    if (nil != _manager) {
        [self failedToStartAdvertise];
        return;
    }
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)stopAdvertising
{
    [_manager stopAdvertising];
}

#pragma mark - private methods

- (NSArray*)setupServices
{
    CBMutableCharacteristic* characteristic = nil;
    
    // assemble major&minor to uuid
    if (nil != self.major && nil != self.minor) {
        uint32_t characteristicUUID32[16];
        memset(characteristicUUID32, 0x0, 16);
        characteristicUUID32[0] = (([self.major unsignedShortValue]) << 16) | [self.minor unsignedShortValue];
        NSData* dataUUID = [NSData dataWithBytes:&characteristicUUID32 length:16];
        CBUUID* characteristicUUID = [CBUUID UUIDWithData:dataUUID];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    }
    
    CBMutableService* service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:self.uuid] primary:YES];
    
    if (nil != characteristic) {
        service.characteristics = @[characteristic];
    }
    
    _service = service;
    
    return @[service];
}

- (void)publishServices
{
    for (CBMutableService* service in [self setupServices]) {
        [_manager addService:service];
    }
}

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
            [self publishServices];
            break;
        default:
            NSLog(@"Central Manager did change state");
            [self failedToStartAdvertise];
            _manager = nil;
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
        [self failedToStartAdvertise];
        _manager = nil;
        return ;
    }
    
    NSLog(@"didAddService");
    
    [_manager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[_service.UUID], CBAdvertisementDataLocalNameKey : @"bluetooth peripheral"}];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
        [self failedToStartAdvertise];
        _manager = nil;
        return ;
    }
    
    NSLog(@"peripheralManagerDidStartAdvertising");
    
    [self successToStartAdvertise];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    [_manager respondToRequest:request withResult:CBATTErrorInvalidOffset];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic %@", characteristic);
}

@end
