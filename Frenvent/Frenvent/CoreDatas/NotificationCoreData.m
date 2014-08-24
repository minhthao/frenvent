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
 * Get the display notifications from the core data.
 * @return Array of Notification
 */
+ (NSArray *) getNotifications {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification"
                                              inManagedObjectContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:false selector:nil];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sort, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *notifications = [context executeFetchRequest:fetchRequest error:&error];
    
    if (notifications == nil) NSLog(@"Error get notifications %@", error);
    
    return notifications;
}

/**
 * Remove all notifications from the core data
 */
+ (void) removeAllNotifications {
    NSArray *items = [self getNotifications];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting notifications - error:%@", error);
}

/**
 * Remove a specific notifications from core data
 * @param notification
 */
+ (void) removeNotification:(Notification *)notification {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:notification];
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting notifications - error:%@", error);
}

/**
 * Add a new friend events notification to the core data
 * @param event
 * @param friend
 * @return notification
 */
+ (Notification *) addNotificationForEvent:(Event *)event andFriend:(Friend *)friend {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification"
                                              inManagedObjectContext:context];

    Notification *notification = [[Notification alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    notification.time = [NSNumber numberWithLongLong:[TimeSupport getCurrentTimeInUnix]];
    notification.event = event;
    notification.friend = friend;
    
    NSError *addingError = nil;
    if (![context save:&addingError]) NSLog(@"Error adding notification - error:%@", addingError);
    return notification;
}

/**
 * Add a new friend events notification to the core data
 * @param event
 * @param friend
 * @param time
 * @return notification
 */
+ (Notification *) addNotificationForEvent:(Event *)event andFriend:(Friend *)friend andTime:(NSNumber *)time{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification"
                                              inManagedObjectContext:context];
    
    Notification *notification = [[Notification alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    notification.time = time;
    notification.event = event;
    notification.friend = friend;
    
    NSError *addingError = nil;
    if (![context save:&addingError]) NSLog(@"Error adding notification - error:%@", addingError);
    return notification;
}


@end
