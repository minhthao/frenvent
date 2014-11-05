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

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LoginViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet FBLoginView *loginView;

@end

@implementation LoginViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginView.delegate = self;
    self.loginView.readPermissions = @[@"user_events", @"email", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"];
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

#pragma mark - Login methods
- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:FB_LOGIN_USER_ID] == nil) {
    
        [defaults setObject:[user objectID] forKey:FB_LOGIN_USER_ID];
        [defaults setObject:[user name] forKey:FB_LOGIN_USER_NAME];
        [defaults setObject:[user objectForKey:@"gender"] forKey:FB_LOGIN_USER_GENDER];
        NSString *email = [user objectForKey:@"email"] ? [user objectForKey:@"email"] : @"";
        [defaults setObject:email forKey:FB_LOGIN_USER_EMAIL];
        
        [defaults synchronize];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        // The following line must only run under iOS 8. This runtime check prevents
        // it from running if it doesn't exist (such as running under iOS 7 or earlier).
        if ([[self locationManager] respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [[self locationManager] requestAlwaysAuthorization];
        }
#endif
        
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

@end
