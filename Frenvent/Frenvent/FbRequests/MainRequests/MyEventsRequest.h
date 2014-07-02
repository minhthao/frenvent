//
//  MyEventsRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyEventsRequestDelegate <NSObject>
@optional
- (void)notifyMyEventsQueryCompleted;   //this should be done during login. Would get all the past and future events
- (void)notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents;  //do during refresh
@end

@interface MyEventsRequest : NSObject

@property (nonatomic, weak) id <MyEventsRequestDelegate> delegate;

- (void) initFriendEvents;
- (void) refreshFriendEvents;
- (void) updateBackgroundFriendEvents;

@end
