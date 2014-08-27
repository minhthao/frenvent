//
//  FriendCoreData.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/26/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendCoreData.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "FriendToEventCoreData.h"
#import "TimeSupport.h"

@interface FriendCoreData()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
+ (NSArray *) getFriend:(NSPredicate *)predicates;

@end

@implementation FriendCoreData

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
+ (NSArray *) getFriend:(NSPredicate *)predicates {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend"
                                              inManagedObjectContext:context];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:nil];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sort, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setSortDescriptors:sortDescriptors];
    if (predicates != nil)[fetchRequest setPredicate:predicates];
    
    NSError *error = nil;
    NSArray *friends = [context executeFetchRequest:fetchRequest error:&error];
    
    if (friends == nil) NSLog(@"Error get Friends %@", error);
    
    return friends;
}


#pragma mark - public methods
/**
 * Add a friend to the core data
 * @param uid
 * @param name
 * @return added Friend
 */
+ (Friend *) addFriend:(NSString *)uid :(NSString *)name {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend"
                                              inManagedObjectContext:context];
    
    Friend *friend = [[Friend alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    friend.uid = uid;
    friend.name = name;
    friend.cover = @"";
    friend.mark = [NSNumber numberWithBool:false];
    friend.favorite = [NSNumber numberWithBool:false];
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error adding friend - error:%@", error);
    
    return friend;
}

/**
 * Add a friend to the core data
 * @param uid
 * @param name
 * @param cover
 * @return added Friend
 */
+ (Friend *) addFriend:(NSString *)uid :(NSString *)name :(NSString *)cover{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend"
                                              inManagedObjectContext:context];
    
    Friend *friend = [[Friend alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    friend.uid = uid;
    friend.name = name;
    friend.cover = cover;
    friend.mark = [NSNumber numberWithBool:false];
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error adding friend - error:%@", error);
    
    return friend;
}

/**
 * Check if this friend has been properly stored in the core data
 * @param uid
 * @return boolean
 */
+ (Friend *) getFriendWithUid:(NSString *)uid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    NSArray *friends = [self getFriend:predicate];
    if (friends.count > 0) return [friends objectAtIndex:0];
    return nil;
}

/**
 * Get all the friends stored in the core data
 * @return Array of Friend
 */
+ (NSArray *) getAllFriends {
    return [self getFriend:nil];
}

/**
 * Get all the favorite friends in the core data
 * @return Array of Friends
 */
+ (NSArray *) getAllFavoriteFriends {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite = 1"];
    return [self getFriend:predicate];
}

/**
 * Get all the future events pertaining to the given user
 * @param uid
 * @return Array of Event
 */
+ (NSArray *) getAllFutureEventsPertainingToUser:(NSString *)uid{
    Friend *friend = [self getFriendWithUid:uid];
    if (friend != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime >= %lld", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
        NSArray *unsortedEvents = [[friend.eventsInterested filteredSetUsingPredicate:predicate] allObjects];
        NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES];
        return [unsortedEvents sortedArrayUsingDescriptors:@[sort]];
    }
    return nil;
}

/**
 * Get all the past events pertaining to a the given user
 * @param uid
 * @return Array of Event
 */
+ (NSArray *) getAllPastEventsPertainingToUser:(NSString *)uid {
    Friend *friend = [self getFriendWithUid:uid];
    if (friend != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime < %lld", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
        NSArray *unsortedEvents = [[friend.eventsInterested filteredSetUsingPredicate:predicate] allObjects];
        NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO];
        return [unsortedEvents sortedArrayUsingDescriptors:@[sort]];
    }
    return nil;
}

/**
 * Mark a friend so it will not need to be resuplied in event query
 * @param Friend
 */
+ (void) markFriend:(Friend *)friend {
    NSManagedObjectContext *context = [self managedObjectContext];
    friend.mark = [NSNumber numberWithBool:true];
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error mark friend - error:%@", error);
}

+ (void) setFriend:(Friend *)friend toFavorite:(BOOL)favorite {
     NSManagedObjectContext *context = [self managedObjectContext];
    friend.favorite = [NSNumber numberWithBool:favorite];
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error changing friend's favorite - error:%@", error);
}

/**
 * Update friend's cover picture
 * @param friend
 * @param cover
 */
+ (void) updateFriendCover:(Friend *)friend :(NSString *)cover {
    NSManagedObjectContext *context = [self managedObjectContext];
    friend.cover = cover;
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error update cover for friend - error:%@", error);
}

/**
 * Remove all friends from the database. Do this when user logged out
 **/
+ (void) removeAllFriends {
    NSArray *items = [self getAllFriends];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting Friends - error:%@", error);

}

@end
