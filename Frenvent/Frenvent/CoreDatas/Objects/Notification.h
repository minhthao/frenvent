//
//  Notification.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/13/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSInteger const TYPE_NEW_INVITE;
extern NSInteger const TYPE_FRIEND_EVENT;

@class Event, Friend;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSOrderedSet *friends;
@end

@interface Notification (CoreDataGeneratedAccessors)

- (void)insertObject:(Friend *)value inFriendsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFriendsAtIndex:(NSUInteger)idx;
- (void)insertFriends:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFriendsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFriendsAtIndex:(NSUInteger)idx withObject:(Friend *)value;
- (void)replaceFriendsAtIndexes:(NSIndexSet *)indexes withFriends:(NSArray *)values;
- (void)addFriendsObject:(Friend *)value;
- (void)removeFriendsObject:(Friend *)value;
- (void)addFriends:(NSOrderedSet *)values;
- (void)removeFriends:(NSOrderedSet *)values;
@end
