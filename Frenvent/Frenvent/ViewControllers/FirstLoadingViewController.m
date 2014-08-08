//
//  FirstLoadingViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FirstLoadingViewController.h"
#import "FriendEventsRequest.h"
#import "MyEventsRequest.h"
#import "FriendsRequest.h"
#import "DbEventsRequest.h"
#import "DbUserRequest.h"
#import "EventCoreData.h"
#import "FriendCoreData.h"
#import "Constants.h"

static NSInteger NUM_QUERIES = 4; //one for friends event, one for my events, one for friends, one for nearby
NSInteger numQueriesDone;
NSInteger numFriendsEvents;
NSInteger numMyEvents;

@interface FirstLoadingViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation FirstLoadingViewController 

#pragma mark - view controller inheritance

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    numQueriesDone = 0;
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        [[self locationManager] startUpdatingLocation];
    else numQueriesDone++;
    
    FriendEventsRequest *friendEventsRequest = [[FriendEventsRequest alloc] init];
    MyEventsRequest *myEventsRequest = [[MyEventsRequest alloc] init];
    FriendsRequest *friendsRequest = [[FriendsRequest alloc] init];
    [friendEventsRequest setDelegate:self];
    [myEventsRequest setDelegate:self];
    [friendsRequest setDelegate:self];
    
    [friendEventsRequest initFriendEvents];
    [myEventsRequest initMyEvents];
    [friendsRequest initFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegates

//delegate for FriendEventsRequest
- (void) notifyFriendEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    numFriendsEvents = [allEvents count];
    DbEventsRequest * dbEventsRequest = [[DbEventsRequest alloc] init];
    [dbEventsRequest setDelegate:self];
    [dbEventsRequest uploadEvents:allEvents];
}

//delegate for friend events request error
- (void) notifyFriendEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];

}

//delegate for MyEventsRequest
- (void) notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    numMyEvents = [allEvents count];
    DbEventsRequest * dbEventsRequest = [[DbEventsRequest alloc] init];
    [dbEventsRequest setDelegate:self];
    [dbEventsRequest uploadEvents:allEvents];
}

//delegate for my events request error
-(void) notifyMyEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

//delegate for FriendsRequest
- (void) notifyFriendsQueryCompleted {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

//delegate for friends request error
- (void) notifyFriendsQueryError {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

//delegate for DbEventsRequest
- (void) notifyEventsUploaded {
    numQueriesDone++;
    [self checkIfAllQueryCompleted];
}

- (void) notifyNearbyEventsInitialized {
    numQueriesDone++;
    [self checkIfAllQueryCompleted];
}

- (void) notifyEventRequestFailure {
    numQueriesDone++;
    [self checkIfAllQueryCompleted];
}

//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations != nil && [locations count] > 0) {
        CLLocation *currentLocation = [locations objectAtIndex:0];
        DbEventsRequest *dbEventsRequest = [[DbEventsRequest alloc] init];
        [dbEventsRequest setDelegate:self];
        [dbEventsRequest initNearbyEvents:(double)[currentLocation coordinate].longitude :(double)[currentLocation coordinate].latitude];
        [[self locationManager] stopUpdatingLocation];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

#pragma mark - private methods
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

/**
 * Check if all tasks are completed. If so, then segue to the main view
 */
- (void) checkIfAllQueryCompleted {
    if (numQueriesDone == NUM_QUERIES) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uid = [defaults stringForKey:FB_LOGIN_USER_ID];
        NSString *name = [defaults stringForKey:FB_LOGIN_USER_NAME];
        
        [defaults setBool:true forKey:LOGIN_DATA_INITIALIZED];
        [defaults synchronize];
        
        DbUserRequest *userRequest = [[DbUserRequest alloc] init];
        [userRequest registerUser:uid :name :numFriendsEvents :numMyEvents];
        [self performSegueWithIdentifier:@"mainViewWithInitialize" sender:Nil];
    }
}

@end
