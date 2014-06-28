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

@interface LoginViewController () <FBLoginViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, weak) IBOutlet FBLoginView *loginView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginView.delegate = self;
    if ([FBSession activeSession].isOpen) {
        [self performSegueWithIdentifier:@"mainViewWithoutInitialize" sender:nil];
    } else {
        self.loginView.readPermissions = @[@"user_events", @"friends_events", @"friends_work_history", @"read_stream"];
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
    
    [defaults setObject:[user objectID] forKey:FB_LOGIN_USER_ID];
    [defaults setObject:[user name] forKey:FB_LOGIN_USER_NAME];
    [defaults setObject:[user objectForKey:@"gender"] forKey:FB_LOGIN_USER_GENDER];
    
    [defaults synchronize];
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
        [self performSegueWithIdentifier:@"mainViewWithoutInitialize" sender:nil];
    } else {
        [[self locationManager] startUpdatingLocation];
    }
}

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"soething");
}

#pragma mark - location manager delegates
//delegate for location manager, call back for reauthorization
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (!status == kCLAuthorizationStatusNotDetermined) {
        [self performSegueWithIdentifier:@"mainViewWithoutInitialize" sender:nil];
    }
}

//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[self locationManager] stopUpdatingLocation];
}

#pragma mark - private methods
/**
 * Lazily obtain the managed object context
 * @return managed object context
 */
+ (CLLocationManager *) locationManager {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] locationManager];
}

@end
