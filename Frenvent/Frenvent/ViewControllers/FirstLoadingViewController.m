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
#import "DBNotificationRequest.h"
#import "TimeSupport.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FriendManager.h"
#import "UITableView+NXEmptyView.h"
#import "MyColor.h"
#import "ToastView.h"

static NSInteger NUM_QUERIES = 4; //one for friends event, one for my events, one for friends, one for nearby
NSInteger numQueriesDone;
NSInteger numFriendsEvents;
NSInteger numMyEvents;

NSInteger quotePos;

@interface FirstLoadingViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) FriendEventsRequest *friendEventsRequest;
@property (nonatomic, strong) MyEventsRequest *myEventsRequest;
@property (nonatomic, strong) FriendsRequest *friendsRequest;
@property (nonatomic, strong) DbEventsRequest *dbEventsRequest;
@property (nonatomic, strong) NSMutableArray *quoteArray;

@end

@implementation FirstLoadingViewController 

#pragma mark - initiation
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
 * Lazily instantiate the friendEventsRequest
 * @return FriendEventsRequest
 */
- (FriendEventsRequest *)friendEventsRequest{
    if (_friendEventsRequest == nil) {
        _friendEventsRequest = [[FriendEventsRequest alloc] init];
        _friendEventsRequest.delegate = self;
    }
    return _friendEventsRequest;
}

/**
 * Lazily instantiate myEventsRequest
 * @return MyEventsRequest
 */
- (MyEventsRequest *)myEventsRequest {
    if (_myEventsRequest == nil) {
        _myEventsRequest = [[MyEventsRequest alloc] init];
        _myEventsRequest.delegate = self;
    }
    return _myEventsRequest;
}

/**
 * Lazily instantiate friendsRequest
 * @return FriendsRequest
 */
- (FriendsRequest *)friendsRequest {
    if (_friendsRequest == nil) {
        _friendsRequest = [[FriendsRequest alloc] init];
        _friendsRequest.delegate = self;
    }
    return _friendsRequest;
}

/**
 * Lazily instantiate the db event requests
 * @return DbEventsRequest
 */
- (DbEventsRequest *)dbEventsRequest {
    if (_dbEventsRequest == nil) {
        _dbEventsRequest = [[DbEventsRequest alloc] init];
        _dbEventsRequest.delegate = self;
    }
    return _dbEventsRequest;
}

/**
 * Lazily instantiate the quote array
 * @return NSArray
 */
-(NSMutableArray *)quoteArray {
    if (_quoteArray == nil) {
        _quoteArray = [[NSMutableArray alloc] init];
        [_quoteArray addObject:@"Configure initial settings"];
        [_quoteArray addObject:@"Getting a lot of events"];
        [_quoteArray addObject:@"Getting suggested companions"];
        [_quoteArray addObject:@"Loading graphic data"];
        [_quoteArray addObject:@"Finishing up, please wait ..."];
    }
    return _quoteArray;
}

#pragma mark - friend events delegate
- (void) notifyFriendEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    numFriendsEvents = [allEvents count];
    [[self dbEventsRequest] uploadEvents:allEvents];
}

- (void) notifyFriendEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
    
}

#pragma mark - my events delegate
- (void) notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    numMyEvents = 0;
    int64_t todayTime = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    for (Event *event in allEvents) {
        if ([event.startTime longLongValue] >= todayTime) numMyEvents++;
    }
    
    [[self dbEventsRequest] uploadEvents:allEvents];
}

-(void) notifyMyEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

#pragma mark - friends delegate
- (void) notifyFriendsQueryCompleted {
    numQueriesDone ++;
   [self checkIfAllQueryCompleted];
}

- (void) notifyFriendsQueryError {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

#pragma mark - delegate for server requests
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

#pragma mark - notification delegate
- (void) notifyNotificationComplete {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [defaults stringForKey:FB_LOGIN_USER_ID];
    NSString *name = [defaults stringForKey:FB_LOGIN_USER_NAME];
    
    [defaults setBool:true forKey:LOGIN_DATA_INITIALIZED];
    [defaults synchronize];
    
    DbUserRequest *userRequest = [[DbUserRequest alloc] init];
    [userRequest registerUser:uid :name :numFriendsEvents :numMyEvents];
    [self performSelector:@selector(goToMainView) withObject:nil afterDelay:0.2];
}

#pragma mark - location manager delegate
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    if (locations != nil && [locations count] > 0) {
        CLLocation *currentLocation = [locations objectAtIndex:0];
        [[self dbEventsRequest] initNearbyEvents:(double)[currentLocation coordinate].longitude :(double)[currentLocation coordinate].latitude];
    } else {
        numQueriesDone ++;
        [self checkIfAllQueryCompleted];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

#pragma mark - view controller delegate
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    [self.loadingImage setImage:[UIImage animatedImageNamed:@"loading" duration:1.0f]];
    quotePos = 0;
    self.loadingText.text = [[self quoteArray] objectAtIndex:0];
    [self animatedLabel];
    
    numQueriesDone = 0;
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        [[self locationManager] startUpdatingLocation];
    else numQueriesDone++;
    
    [[self friendsRequest] initFriends];
    [[self friendEventsRequest] initFriendEvents];
    [[self myEventsRequest] initMyEvents];
}

- (void)animatedLabel {
    [UIView transitionWithView:self.loadingText duration:3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    } completion:^(BOOL finished) {
        if (quotePos != [[self quoteArray] count] - 1) {
            quotePos ++;
            self.loadingText.text = [[self quoteArray] objectAtIndex:quotePos];
            [self animatedLabel];
        }
    }];
}

#pragma mark - selector for navigating within the view
- (void)goToMainView {
    [self performSegueWithIdentifier:@"mainViewWithInitialize" sender:Nil];
}

/**
 * Check if all tasks are completed. If so, then segue to the main view
 */
- (void) checkIfAllQueryCompleted {
    if (numQueriesDone == NUM_QUERIES) {
        DBNotificationRequest *notificationRequest = [[DBNotificationRequest alloc] init];
        notificationRequest.delegate = self;
        [notificationRequest getNotifications];
    }
}


@end
