//
//  LoginViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/27/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LoginViewController.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet FBLoginView *loginView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginView.delegate = self;
    self.loginView.readPermissions = @[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    if ([FBSession activeSession].isOpen) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:LOGIN_DATA_INITIALIZED])
            [self performSegueWithIdentifier:@"mainViewWithoutInitialize" sender:Nil];
        else [self performSegueWithIdentifier:@"initialize" sender:Nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Login methods
- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:FB_LOGIN_USER_ID] == nil) {
    
        [defaults setObject:[user objectID] forKey:FB_LOGIN_USER_ID];
        [defaults setObject:[user name] forKey:FB_LOGIN_USER_NAME];
        [defaults setObject:[user objectForKey:@"gender"] forKey:FB_LOGIN_USER_GENDER];

        [defaults synchronize];

        if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
            [self performSegueWithIdentifier:@"initialize" sender:Nil];
        else [[self locationManager] startUpdatingLocation];
    }
}

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView {
}

#pragma mark - location manager delegates
//delegate for location manager, call back for reauthorization
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined)
        [self performSegueWithIdentifier:@"initialize" sender:Nil];
}

//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[self locationManager] stopUpdatingLocation];
}

#pragma mark - property
/**
 * Lazily obtain the managed object context
 * @return location manager
 */
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

@end
