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
#import "FriendToEventCoreData.h"
#import "FriendCoreData.h"
#import "Constants.h"

static NSInteger NUM_QUERIES = 5; //one for friends event, one for my events, one for friends, one for notification, one for nearby
NSInteger numQueriesDone;
NSInteger numFriendsEvents;
NSInteger numMyEvents;

NSTimeInterval timeCost;
NSTimeInterval startTime;

@interface FirstLoadingViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
- (void) checkIfAllQueryCompleted;

@end

@implementation FirstLoadingViewController 


- (void)viewDidLoad
{
    [super viewDidLoad];
    [EventCoreData removeAllEvents];
    [FriendToEventCoreData removeAllFriendToEventPairs];
    [FriendCoreData removeAllFriends];
    
    numQueriesDone = 0;
    
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
//        [[self locationManager] startUpdatingLocation];
//    else numQueriesDone++;
    
    FriendEventsRequest *friendEventsRequest = [[FriendEventsRequest alloc] init];
    MyEventsRequest *myEventsRequest = [[MyEventsRequest alloc] init];
    FriendsRequest *friendsRequest = [[FriendsRequest alloc] init];
    [friendEventsRequest setDelegate:self];
    [myEventsRequest setDelegate:self];
    [friendsRequest setDelegate:self];
    
    startTime = [[[NSDate alloc] init] timeIntervalSince1970];
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
    NSTimeInterval rightNow = [[[NSDate alloc] init] timeIntervalSince1970];
    NSLog(@"Friend events query completed in %f with %d result", rightNow - startTime, [allEvents count]);
    
    
    
//    numFriendsEvents = [allEvents count];
//    DbEventsRequest * dbEventsRequest = [[DbEventsRequest alloc] init];
//    [dbEventsRequest setDelegate:self];
//    [dbEventsRequest uploadEvents:allEvents];
}

//delegate for MyEventsRequest
- (void) notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    NSTimeInterval rightNow = [[[NSDate alloc] init] timeIntervalSince1970];
    NSLog(@"My events query completed in %f with %d result", rightNow - startTime, [allEvents count]);
    
//    numMyEvents = [allEvents count];
//    DbEventsRequest * dbEventsRequest = [[DbEventsRequest alloc] init];
//    [dbEventsRequest setDelegate:self];
//    [dbEventsRequest uploadEvents:allEvents];
}

//delegate for FriendsRequest
- (void) notifyFriendsQueryCompleted {
    NSTimeInterval rightNow = [[[NSDate alloc] init] timeIntervalSince1970];
    NSLog(@"Friends query completed in %f", rightNow - startTime);
//    numQueriesDone ++;
//    [self checkIfAllQueryCompleted];
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

//delegate for DbUserRequest
- (void) notifyLoginUserRegistered {
    [self performSegueWithIdentifier:@"mainViewWithInitialize" sender:Nil];
}

//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations != nil && [locations count] > 0) {
        CLLocation *currentLocation = [locations objectAtIndex:0];
        DbEventsRequest *dbEventsRequest = [[DbEventsRequest alloc] init];
        [dbEventsRequest getNearbyEvents:(double)[currentLocation coordinate].longitude :(double)[currentLocation coordinate].latitude];
        [[self locationManager] stopUpdatingLocation];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - private methods
/**
 * Lazily obtain the managed object context
 * @return managed object context
 */
- (CLLocationManager *)locationManager {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self.locationManager;
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
        [userRequest setDelegate:self];
        [userRequest registerUser:uid :name :numFriendsEvents :numMyEvents];
    }
}

@end
