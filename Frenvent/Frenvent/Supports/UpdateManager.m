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

NSInteger numRequestPending;

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
    
}

//delegate for  my events query completion
-(void)notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    
}

//delegate for event upload completion
-(void)notifyEventsUploaded {
    numRequestPending--;
    if (numRequestPending == 0) {
        //TODO, say that fetch have completed successfully
    }
}

- (void)doUpdateWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    numRequestPending = 2; //we update friend events and my events
    [[self myEventsRequest] updateBackgroundMyEvents];
    [[self friendEventsRequest] updateBackgroundFriendEventsWithCompletionHandler:completionHandler];
    
}

@end
