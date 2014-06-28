//
//  Friend.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/26/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendToEvent;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSSet *eventsInterested;
@end

@interface Friend (CoreDataGeneratedAccessors)

- (void)addEventsInterestedObject:(FriendToEvent *)value;
- (void)removeEventsInterestedObject:(FriendToEvent *)value;
- (void)addEventsInterested:(NSSet *)values;
- (void)removeEventsInterested:(NSSet *)values;

@end
