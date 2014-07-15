//
//  Friend.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/13/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * mark;
@property (nonatomic, retain) NSSet *eventsInterested;
@end

@interface Friend (CoreDataGeneratedAccessors)

- (void)addEventsInterestedObject:(Event *)value;
- (void)removeEventsInterestedObject:(Event *)value;
- (void)addEventsInterested:(NSSet *)values;
- (void)removeEventsInterested:(NSSet *)values;

@end
