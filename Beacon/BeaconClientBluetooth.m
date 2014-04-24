//
//  BeaconClientBluetooth.m
//  BeaconEmulator
//
//  Created by ediv on 14-3-26.
//
//

#import "BeaconClientBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface BeaconClientBluetooth () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager* _manager;
    NSMutableArray* _dicoveredPeripherals;
}
@end

@implementation BeaconClientBluetooth

- (id)init
{
    self = [super init];
    
    if (self) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        _dicoveredPeripherals = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - public methods

- (void)startScan
{
    [super startScan];
    
    if (nil != _manager) {
        [self failedToStartScan];
        return;
    }
    
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)stopScan
{
    [super stopScan];
    
    [_manager stopScan];
    
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

#pragma mark - core bluetooth central manager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self scanPeripherals];
            break;
        default:
            [self failedToStartScan];
            _manager = nil;
            NSLog(@"Central Manager did change state");
            break;
    }
}

- (void)scanPeripherals
{
    if (_manager.state != CBCentralManagerStatePoweredOn)
        NSLog (@"CoreBluetooth not initialized correctly!");
    else {
        [_manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.uuid]] options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%@", peripheral);
    
    //加入到被发现的设备列表中
    if(![_dicoveredPeripherals containsObject:peripheral])
    {
        [_dicoveredPeripherals addObject:peripheral];
        [_manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:self.uuid]]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral disConnected : %@", error);
    
    [_manager cancelPeripheralConnection:peripheral];
    peripheral.delegate = nil;
    [_dicoveredPeripherals removeObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Connect error!");
    
    peripheral.delegate = nil;
    [_dicoveredPeripherals removeObject:peripheral];
    peripheral = nil;
}

#pragma mark - CBPeripheral delegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"CBPeripheral %@ ,Error discovering services: %@",peripheral.name,[error localizedDescription]);
        return;
    }
    
    NSArray* characterics = nil;
    
    // assemble major&minor to uuid
    if (nil != self.major && nil != self.minor) {
        uint32_t characteristicUUID32[16];
        memset(characteristicUUID32, 0x0, 16);
        characteristicUUID32[0] = (([self.major unsignedShortValue]) << 16) | [self.minor unsignedShortValue];
        NSData* dataUUID = [NSData dataWithBytes:&characteristicUUID32 length:16];
        CBUUID* uuid = [CBUUID UUIDWithData:dataUUID];
        
        characterics = @[uuid];
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:characterics forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"CBPeripheral %@ ,Error discovering peripheral: %@",peripheral.name,[error localizedDescription]);
        return;
    }
    
    NSMutableArray* notes = [[NSMutableArray alloc] init];
    
    for (CBCharacteristic* characteristic in service.characteristics) {
        NSData* dataUUID = characteristic.UUID.data;
        if (nil == dataUUID.bytes) {
            continue;
        }
        
        uint32_t characteristicUUID = ((uint32_t*)dataUUID.bytes)[0];
        uint16_t major = (uint16_t) (characteristicUUID >> 16);
        uint16_t minor = (uint16_t) (characteristicUUID & 0x0000FFFFuL);
        
        [notes addObject:@{@"uuid" : self.uuid, @"major" : @(major), @"minor" : @(minor)}];
        
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
    
    [self successToDiscover:notes];
}

@end
