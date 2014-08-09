//
//  UpdateManager.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/15/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "UpdateManager.h"
#import "FriendEventsRequest.h"
#import "MyEventsRequest.h"
#import "DbEventsRequest.h"
#import "TimeSupport.h"
#import "NotificationManager.h"
#import "NotificationCoreData.h"

NSInteger numRequestPending;
int64_t fetchStartTime;

@interface UpdateManager()

@property (nonatomic, strong) MyEventsRequest *myEventsRequest;
@property (nonatomic, strong) FriendEventsRequest *friendEventsRequest;
@property (nonatomic, strong) DbEventsRequest *dbEventsRequest;

@end

@implementation UpdateManager

#pragma mark - initiate
// Lazy instantiate my events request
- (MyEventsRequest *)myEventsRequest {
    if (_myEventsRequest == nil) {
        _myEventsRequest = [[MyEventsRequest alloc] init];
        _myEventsRequest.delegate = self;
    }
    return _myEventsRequest;
}

// Lazy instantiate friend events request
- (FriendEventsRequest *)friendEventsRequest {
    if (_friendEventsRequest == nil) {
        _friendEventsRequest = [[FriendEventsRequest alloc] init];
        _friendEventsRequest.delegate = self;
    }
    return _friendEventsRequest;
}

// Lazy instantiate db events request
- (DbEventsRequest *)dbEventsRequest {
    if (_dbEventsRequest == nil) {
        _dbEventsRequest = [[DbEventsRequest alloc] init];
        _dbEventsRequest.delegate = self;
    }
    return _dbEventsRequest;
}

#pragma mark - request delegate
//delegate for friend events query completion
-(void)notifyFriendEventsUpdateCompletedWithNewEvents:(NSArray *)newEvents usingCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (newEvents == nil || [newEvents count] ==0) {
        numRequestPending--;
        [self checkUpdateRequestFinish:completionHandler];
    } else [[self dbEventsRequest] uploadEvents:newEvents withCompletitionHandler:completionHandler];
}

//delegate for friend events error query
-(void)notifyFriendEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    numRequestPending--;
    [self checkUpdateRequestFinish:completionHandler];
}

//delegate for  my events query completion
-(void)notifyMyEventsUpdateCompletedWithNewEvents:(NSArray *)newEvents usingCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    if (newEvents == nil || [newEvents count] ==0) {
        numRequestPending--;
        [self checkUpdateRequestFinish:completionHandler];
    } else [[self dbEventsRequest] uploadEvents:newEvents withCompletitionHandler:completionHandler];
}

//delegate for my events query error
-(void)notifyMyEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    numRequestPending--;
    [self checkUpdateRequestFinish:completionHandler];
}

//delegate for event upload completion
-(void)notifyEventsUploaded:(BOOL)successfullyUploaded WithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    numRequestPending --;
    [self checkUpdateRequestFinish:completionHandler];
}

-(void)notifyEventRequestFailure {
    //do nothing in this case
}

#pragma mark - public methods
/**
 * Call background fetch to do update on events. 
 * @param completion handler from the background fetch
 */
- (void)doUpdateWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    fetchStartTime = [TimeSupport getCurrentTimeInUnix];
    numRequestPending = 2; //we update friend events and my events
    [[self myEventsRequest] updateBackgroundMyEventsWithCompletionHandler:completionHandler];
    [[self friendEventsRequest] updateBackgroundFriendEventsWithCompletionHandler:completionHandler];
    
}

#pragma mark - private methods, call to check of the update finished
-(void)checkUpdateRequestFinish:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (numRequestPending == 0)
        completionHandler(UIBackgroundFetchResultNewData);
}

@end
