//
// Created by Michael Seghers on 13/06/14.
// Copyright (c) 2014 Mobel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BeaconManager : NSObject


- (instancetype) initWithDelegate:(__weak id<CBPeripheralManagerDelegate, CLLocationManagerDelegate>) delegate;

#pragma mark - Advertisement
@property(nonatomic, readonly) BOOL isAdvertising;
- (void) startAdvertisingAsiBeacon;
- (void)stopAdvertising;

#pragma mark - Monitoring
@property(nonatomic, readonly) BOOL canMonitor;
@property(nonatomic, readonly) BOOL isMonitoring;
- (void)startMonitoringiBeacon;
- (void)stopMonitoring;

@end