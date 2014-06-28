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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
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
 */
+ (void) addFriend:(NSString *)uid :(NSString *)name {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend"
                                              inManagedObjectContext:context];
    
    Friend *friend = [[Friend alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    friend.uid = uid;
    friend.name = name;
    
    [context insertObject:friend];
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error adding friend - error:%@", error);
}

/**
 * Check if this friend has been properly stored in the core data
 * @param uid
 * @return boolean
 */
+ (Friend *) getFriendWithUid:(NSString *)uid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    NSArray *friends = [self getFriend:predicate];
    if (friends.count > 0) [friends objectAtIndex:0];
    return nil;
}

/**
 * Get all the friends stored in the core data
 * @param Array of Friend
 */
+ (NSArray *) getAllFriends {
    return [self getFriend:nil];
}

/**
 * Get all the future events pertaining to the given user
 * @param uid
 * @return Array of Event
 */
+ (NSArray *) getAllFutureEventsPertainingToUser:(NSString *)uid {
    return [FriendToEventCoreData getAllFutureEventsPertainingToUser:uid];
}

/**
 * Get all the past events pertaining to a the given user
 * @param uid
 * @return Array of Event
 */
+ (NSArray *) getAllPastEventsPertainingToUser:(NSString *)uid {
    return [FriendToEventCoreData getAllPastEventsPertainingToUser:uid];
}


+ (void) removeAllEvents {
    NSArray *items = [self getAllFriends];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting Friends - error:%@", error);

}

@end