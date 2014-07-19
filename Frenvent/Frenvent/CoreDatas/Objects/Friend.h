//
//  Friend.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Notification;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSNumber * mark;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSSet *eventsInterested;
@property (nonatomic, retain) NSSet *notifications;
@end

@interface Friend (CoreDataGeneratedAccessors)

- (void)addEventsInterestedObject:(Event *)value;
- (void)removeEventsInterestedObject:(Event *)value;
- (void)addEventsInterested:(NSSet *)values;
- (void)removeEventsInterested:(NSSet *)values;

- (void)addNotificationsObject:(Notification *)value;
- (void)removeNotificationsObject:(Notification *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

@end
