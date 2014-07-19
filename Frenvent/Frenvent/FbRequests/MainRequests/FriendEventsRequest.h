//
//  FriendEventsRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/28/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendEventsRequestDelegate <NSObject>
@required
- (void)notifyFriendEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler;
@optional
- (void)notifyFriendEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents;
- (void)notifyFriendEventsUpdateCompletedWithNewEvents:(NSArray *)newEvents usingCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
@end

@interface FriendEventsRequest : NSObject

@property (nonatomic, weak) id <FriendEventsRequestDelegate> delegate;

- (void) initFriendEvents;
- (void) refreshFriendEvents;
- (void) updateBackgroundFriendEventsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end

