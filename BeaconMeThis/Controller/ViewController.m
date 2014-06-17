//
//  ViewController.m
//  BeaconMeThis
//
//  Created by Michael Seghers on 13/06/14.
//  Copyright (c) 2014 Mobel. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ViewController.h"
#import "BeaconManager.h"

@interface ViewController () <CBPeripheralManagerDelegate, CLLocationManagerDelegate> {
    BeaconManager *_beaconManager;
    NSNumberFormatter *_numberFormatter;

    __weak IBOutlet UIButton *_advertiseButton;
    __weak IBOutlet UIButton *_monitorButton;
    __weak IBOutlet UILabel *_statusLabel;
}

@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _initViewController];
    }
    return self;
}

- (void)awakeFromNib {
    [self _initViewController];
}

- (void)_initViewController {
    _beaconManager = [[BeaconManager alloc] initWithDelegate:self];
    _numberFormatter = [[NSNumberFormatter alloc] init];
    _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _advertiseButton.enabled = NO;
    _monitorButton.enabled = [_beaconManager canMonitor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)_advertisingButtonTapped:(id)sender {
    if ([_beaconManager isAdvertising]) {
        [self _stopAdvertising];
    } else {
        [self _advertiseAsIBeacon];
    }
}

- (void)_advertiseAsIBeacon {
    _statusLabel.text = NSLocalizedString(@"Starting advertisement...", @"");
    [_beaconManager startAdvertisingAsiBeacon];
}

- (void)_stopAdvertising {
    _statusLabel.text = NSLocalizedString(@"Stoping advertisement...", @"");
    [_beaconManager stopAdvertising];
    _statusLabel.text = NSLocalizedString(@"Stopped advertisement...", @"");
    [_advertiseButton setTitle:NSLocalizedString(@"Start advertising", @"") forState:UIControlStateNormal];

}

- (IBAction)_monitorButtonTapped:(id)sender {
    if ([_beaconManager isMonitoring]) {
        [self _stopMonitoring];
    } else {
        [self _startMonitoring];
    }
}

- (void)_startMonitoring {
    [_beaconManager startMonitoringiBeacon];
}

- (void)_stopMonitoring {
    [_beaconManager stopMonitoring];
    [_monitorButton setTitle:NSLocalizedString(@"Start monitoring", @"") forState:UIControlStateNormal];
    _statusLabel.text = NSLocalizedString(@"Monitoring stopped...", @"");
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Perpheral manager delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager {


    switch (peripheralManager.state) {
        case CBPeripheralManagerStateUnknown:
            _statusLabel.text = NSLocalizedString(@"Peripheral manager state unknown...", @"");
            _advertiseButton.enabled = NO;
            break;
        case CBPeripheralManagerStateResetting:
            _statusLabel.text = NSLocalizedString(@"Peripheral manager state resetting...", @"");
            _advertiseButton.enabled = NO;
            break;
        case CBPeripheralManagerStateUnsupported:
            _statusLabel.text = NSLocalizedString(@"Your device does not support advertising as iBeacon...", @"");
            _advertiseButton.enabled = NO;
            break;
        case CBPeripheralManagerStateUnauthorized:
            _statusLabel.text = NSLocalizedString(@"Your device is not authorzied to advertise as iBeacon...", @"");
            _advertiseButton.enabled = NO;
            break;
        case CBPeripheralManagerStatePoweredOff:
            _statusLabel.text = NSLocalizedString(@"You should not dissable bluetooth if you want to advertise as iBeacon...", @"");
            _advertiseButton.enabled = NO;
            break;
        case CBPeripheralManagerStatePoweredOn:
            _statusLabel.text = NSLocalizedString(@"Bluetooth is on...", @"");
            _advertiseButton.enabled = YES;
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        _statusLabel.text = NSLocalizedString(@"Peripheral could not advertise, see log...", @"");
        NSLog(@"Advertisement failed: %@", error);
    } else {
        _statusLabel.text = NSLocalizedString(@"Advertisement started, try detecting the beacon with another device!", @"");
        [_advertiseButton setTitle:NSLocalizedString(@"Stop advertising", @"") forState:UIControlStateNormal];
    }
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    _statusLabel.text = NSLocalizedString(@"Monitoring has started...", @"");
    [_monitorButton setTitle:NSLocalizedString(@"Stop monitoring", @"") forState:UIControlStateNormal];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = beacons.firstObject;
    CLLocationAccuracy accuracy = beacon.accuracy;
    CLProximity proximity = beacon.proximity;
    UIColor *toColor;
    switch (proximity) {
        case CLProximityUnknown:
            toColor = [UIColor whiteColor];
            break;
        case CLProximityImmediate:
            toColor = [UIColor redColor];
            break;
        case CLProximityNear:
            toColor = [UIColor orangeColor];
            break;
        case CLProximityFar:
            toColor = [UIColor greenColor];
            break;
    }

    [UIView animateWithDuration:0.6 animations:^{
        self.view.backgroundColor = toColor;
    }];

    _statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"RSSI range is %d with an accuracy of ± %@ m", @""), beacon.rssi, [_numberFormatter stringFromNumber:@(accuracy)]];
}


@end