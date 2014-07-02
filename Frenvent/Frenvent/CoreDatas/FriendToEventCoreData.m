//
//  FriendToEventCoreData.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/26/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendToEventCoreData.h"
#import "FriendToEvent.h"
#import "AppDelegate.h"
#import "TimeSupport.h"

@interface FriendToEventCoreData()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (NSArray *) getFriendToEventPairs:(NSPredicate *)predicates;

@end

@implementation FriendToEventCoreData

#pragma mark - private methods
/**
 * Lazily obtain the managed object context
 * @return managed object context
 */
+ (NSManagedObjectContext *) managedObjectContext {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

/**
 * Get all the friend to event pair stored in the core data using the given set of predicates
 * @param predicates
 * @return Array of Event
 */
+ (NSArray *) getFriendToEventPairs:(NSPredicate *)predicates {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendToEvent"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    if (predicates != nil)[fetchRequest setPredicate:predicates];
    
    NSError *error = nil;
    NSArray *friendToEventPairs = [context executeFetchRequest:fetchRequest error:&error];
    
    if (friendToEventPairs == nil) NSLog(@"Error getting friend-to-event pairs - %@", error);
    
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (FriendToEvent *friendToEvent in friendToEventPairs) {
    	[events addObject:friendToEvent.event];
    }
    
    return events;

}


#pragma mark - public methods
/**
 * Add an friend to event pair to the core data. When adding the FriendToEvent pair,
 * The object Event and Friend must be change to reflect this as well
 * @param Event
 * @param Friend
 */
+ (void) addFriendToEventPair:(Event *)event :(Friend *)friend {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendToEvent"
                                              inManagedObjectContext:context];

    FriendToEvent *friendToEvent = [[FriendToEvent alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    
    friendToEvent.friend = friend;
    friendToEvent.event = event;
    friendToEvent.eid = event.eid;
    friendToEvent.startTime = event.startTime;
    friendToEvent.uid = friend.uid;
    friendToEvent.name = friend.name;
    
    //here, we all the friend to event pair to both the friend and event managed objects
    [friend addEventsInterestedObject:friendToEvent];
    [event addFriendsInterestedObject:friendToEvent];
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error adding friend to event pair - error:%@", error);

}

/**
 * Check if an friend to event pair is already exist
 * @param eid
 * @param uid
 * @return boolean
 */
+ (BOOL) isFriendToEventPairExist:(NSString *)eid :(NSString *)uid {
    NSPredicate *eidPredicate = [NSPredicate predicateWithFormat:@"eid = %@", eid];
    NSPredicate *uidPredicate = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[eidPredicate, uidPredicate]];
    
    NSArray *events = [self getFriendToEventPairs:predicates];
    if (events.count > 0) return TRUE;
    return FALSE;
}

/**
 * Get all the ongoing event pertaining to a given user
 * @param uid
 * @return Array of Event
 */
+ (NSArray *) getAllFutureEventsPertainingToUser:(NSString *)uid {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, userPredicate]];
    
    NSArray *friendToEventPairs = [self getFriendToEventPairs:predicates];
    
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (FriendToEvent *friendToEvent in friendToEventPairs) {
    	[events addObject:friendToEvent.event];
    }
    
    return events;
}

/**
 * Get all the ongoing event pertaining to a given user
 * @param uid
 * @return Array of Event
 */
+ (NSArray *) getAllPastEventsPertainingToUser:(NSString *)uid {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, userPredicate]];
    NSArray *friendToEventPairs = [self getFriendToEventPairs:predicates];
    
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (FriendToEvent *friendToEvent in friendToEventPairs) {
    	[events addObject:friendToEvent.event];
    }
    
    return events;
}

/**
 * Remove all the friend to event pairs stored in the core data.
 * This should only be use during logout
 */
+ (void) removeAllFriendToEventPairs {
    NSArray *items = [self getFriendToEventPairs:nil];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting friend-to-event pairs - error:%@", error);
}

/**
 * Remove all the friend to event pairs that is associating with a given event.
 * This should only be use during the removal of specific event
 * @param eid
 */
+ (void) removeAllFriendToEventPairsAssociateWithEvent:(NSString *)eid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eid = %@", eid];
    NSArray *items = [self getFriendToEventPairs:predicate];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting friend-to-event pairs - error:%@", error);
}



@end
