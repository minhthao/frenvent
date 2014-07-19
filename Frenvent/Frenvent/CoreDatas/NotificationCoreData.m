//
//  NotificationCoreData.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/3/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "NotificationCoreData.h"
#import "AppDelegate.h"
#import "Notification.h"
#import "TimeSupport.h"
#import "Event.h"
#import "Friend.h"

@interface NotificationCoreData()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation NotificationCoreData

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
 * Get the display notifications from the core data. The display notifications will be in
 * type: daily_notification, friend_event, and new_invite
 * @return Array of Notification
 */
+ (NSArray *) getNotifications:(NSPredicate *)predicates {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification"
                                              inManagedObjectContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:false selector:nil];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sort, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setSortDescriptors:sortDescriptors];
    if (predicates != nil) [fetchRequest setPredicate:predicates];
    
    NSError *error = nil;
    NSArray *notifications = [context executeFetchRequest:fetchRequest error:&error];
    
    if (notifications == nil) NSLog(@"Error get notifications %@", error);
    
    return notifications;
}

/**
 * Get all the notifications from the core data since the given start time. 
 * @param since time
 * @return Array of Notification
 */
+ (NSArray *) getNotificationsSince:(int64_t)sinceTime {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time = %d", sinceTime];
    return [self getNotifications:predicate];
}

/**
 * Get all the notifications of a type from the core data since the given start time.
 * @param since time
 * @return Array of Notification
 */
+ (NSArray *) getNotificationsSince:(int64_t)sinceTime ofType:(NSInteger)type{
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"time = %d", sinceTime];
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type = %d", type];
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, typePredicate]];
    return [self getNotifications:predicates];
}

/**
 * Remove all notifications from the core data
 */
+ (void) removeAllNotifications {
    NSArray *items = [self getNotifications:nil];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting notifications - error:%@", error);
}

/**
 * Add a new invited notification to the core data
 * @param event
 * @return notification
 */
+ (Notification *) addNewInvitedNotification:(Event *)event  {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification"
                                              inManagedObjectContext:context];
    
    Notification *notification = [[Notification alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    
    notification.type = [NSNumber numberWithInteger:TYPE_NEW_INVITE];
    notification.time = [NSNumber numberWithLongLong:[TimeSupport getCurrentTimeInUnix]];
    notification.event = event;
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error adding notification - error:%@", error);

    return notification;
}

/**
 * Add a new friend events notification to the core data
 * @param event
 * @param friend
 * @return notification
 */
+ (Notification *) addNewNotificationForEvent:(Event *)event andFriend:(Friend *)friend {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification"
                                              inManagedObjectContext:context];
    
    //we first check if the notification for such event exist, if so just update the list of friends
    NSPredicate *eidPredicate = [NSPredicate predicateWithFormat:@"event.eid = %@", event.eid];
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type = %d", TYPE_FRIEND_EVENT];
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[eidPredicate, typePredicate]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicates];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSError *error = nil;
    NSArray *notifications = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([notifications count] > 0) {
        //we simply add the friend into the set of notification
        Notification *notification = [notifications objectAtIndex:0];
        notification.time = [NSNumber numberWithLongLong:[TimeSupport getCurrentTimeInUnix]];
        [notification insertObject:friend inFriendsAtIndex:0];
        
        NSError *updateError = nil;
        if (![context save:&updateError]) NSLog(@"Error updating notification - error:%@", updateError);
        return notification;
    } else {
        if (notifications == nil) NSLog(@"Error fetching friend notification - error:%@", error);
        
        Notification *notification = [[Notification alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        
        notification.type = [NSNumber numberWithInteger:TYPE_FRIEND_EVENT];
        notification.time = [NSNumber numberWithLongLong:[TimeSupport getCurrentTimeInUnix]];
        notification.event = event;
        [notification addFriendsObject:friend];
        
        NSError *addingError = nil;
        if (![context save:&addingError]) NSLog(@"Error adding notification - error:%@", addingError);
        return notification;
    }
}


@end
