//
//  FriendToEventCoreData.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendToEventCoreData.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "Event.h"
#import "EventCoreData.h"
#import "TimeSupport.h"

@interface FriendToEventCoreData()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
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


#pragma mark - public methods
/**
 * Add an friend to event pair to the core data. When adding the FriendToEvent pair,
 * The object Event and Friend must be change to reflect this as well
 * @param Event
 * @param Friend
 */
+ (void) addFriendToEventPair:(Event *)event :(Friend *)friend {
    NSManagedObjectContext *context = [self managedObjectContext];
    //here, we all the friend to event pair to both the friend and event managed objects
    [friend addEventsInterestedObject:event];
    [event addFriendsInterestedObject:friend];
    
    
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
    NSPredicate *uidPredicate = [NSPredicate predicateWithFormat:@"ANY friendsInterested.uid = %@", uid];
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[eidPredicate, uidPredicate]];
    
    NSArray *events = [EventCoreData getEvents:predicates sortByDateAsc:true];
    if (events.count > 0) return TRUE;
    return FALSE;
}

@end