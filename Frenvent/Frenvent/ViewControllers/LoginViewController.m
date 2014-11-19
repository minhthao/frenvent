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
#import "MyColor.h"

BOOL didGoToInitView;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    didGoToInitView = false;
    self.loginView.delegate = self;
    self.loginView.readPermissions = @[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"];
    
    for(id object in self.loginView.subviews){
        if([[object class] isSubclassOfClass:[UIButton class]]){
            UIButton* button = (UIButton*)object;
            [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [button addTarget:self action:@selector(openFacebookAuthentication) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [self.guestButton.layer setCornerRadius:20];
    [self.guestButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.guestButton.layer setBorderWidth:1];
}


-(void)openFacebookAuthentication {
    NSArray *permission = @[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"];
    
    [FBSession setActiveSession: [[FBSession alloc] initWithPermissions:permission] ];
    
    [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) { }];
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
        
        [defaults synchronize];
        
        if ([[self locationManager] respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [[self locationManager] requestAlwaysAuthorization];
        }
        
        if ((![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) && !didGoToInitView) {
            didGoToInitView = YES;
            [self performSegueWithIdentifier:@"initialize" sender:Nil];
        } else [[self locationManager] startUpdatingLocation];
    }
}

#pragma mark - location manager delegates
//delegate for location manager, call back for reauthorization
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined && !didGoToInitView) {
        didGoToInitView = YES;
        [self performSegueWithIdentifier:@"initialize" sender:Nil];
    }
}

//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[self locationManager] stopUpdatingLocation];
}

- (IBAction)continueAsGuestClick:(id)sender {
    [self performSegueWithIdentifier:@"guestView" sender:Nil];
}
@end
