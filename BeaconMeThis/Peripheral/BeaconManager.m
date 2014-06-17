//
// Created by Michael Seghers on 13/06/14.
// Copyright (c) 2014 Mobel. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BeaconManager.h"

#define PROXIMITY_UUID_STRING @"61CE8B3B-15BB-4751-B0E0-5225617DA887"

#define BEACON_REGION_IDENTIFIER @"io.mobel.region"

@interface BeaconManager () <CLLocationManagerDelegate> {
    CBPeripheralManager *_peripheralManager;
    CLLocationManager *_locationManager;
    CLBeaconRegion *_beaconRegion;
    __weak id<CLLocationManagerDelegate> _delegate;
    NSUUID *_proximityUUID;
}

@end

@implementation BeaconManager {
}

- (instancetype)initWithDelegate:(__weak id <CBPeripheralManagerDelegate, CLLocationManagerDelegate>)aDelegate {
    self = [super init];
    if (self) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:aDelegate queue:nil options:nil];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _proximityUUID = [[NSUUID alloc] initWithUUIDString:PROXIMITY_UUID_STRING];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_proximityUUID identifier:BEACON_REGION_IDENTIFIER];
        _delegate = aDelegate;
    }

    return self;
}

#pragma mark - Advertising
- (void)startAdvertisingAsiBeacon {
    NSDictionary *beaconPeripheralData = [_beaconRegion peripheralDataWithMeasuredPower:nil]; //Signal strength

    [_peripheralManager startAdvertising:beaconPeripheralData];
}

- (void)stopAdvertising {
    [_peripheralManager stopAdvertising];
}

- (BOOL)isAdvertising {
    return _peripheralManager.isAdvertising;
}

#pragma mark - Monitoring
- (void) startMonitoringiBeacon {

    [_locationManager startMonitoringForRegion:_beaconRegion];
}

- (void)stopMonitoring {
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    [_locationManager stopMonitoringForRegion:_beaconRegion];
    _isMonitoring = NO;
}

- (BOOL)canMonitor {
    return [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
}

#pragma mark - Location manager delegate
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    _isMonitoring = YES;
    [_delegate locationManager:manager didStartMonitoringForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    [_delegate locationManager:manager didRangeBeacons:beacons inRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    switch (state) {
        case CLRegionStateInside:
              [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            //[self sendLocaleNotificationWithMessage:[NSString stringWithFormat:@"Inside: %@", [_beaconRegion peripheralDataWithMeasuredPower:nil]]];
            break;
        case CLRegionStateOutside:
            [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
            //[self sendLocaleNotificationWithMessage:@"Outside"];
            break;
        case CLRegionStateUnknown:
        default:
            [manager stopRangingBeaconsInRegion:_beaconRegion];
    }
}

@end