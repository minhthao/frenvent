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
+ (NSArray *) getNotifications {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
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
 * Add a notification to the core data
 * @param notification type
 * @param the timestamp at which the notification is being created
 * @param if of type friend_event, uid of friend in which the action is initiated
 * @param if of type friend_event or new_invite, event id
 * @param if of type friend_event or new_invite, event name
 * @param if of type friend_event or new_invite, event picture
 * @param if of type friend_event or new_invite, event start_time
 * @param if of type daily_notification, list of uid of the people going out today
 * @param whether the notification has been viewed
 * @return notification
 */
+ (Notification *) addNotificationWithType:(NSNumber *)type
                          notificationTime:(NSNumber *)time
                                  friendId:(NSString *)friendId
                                friendName:(NSString *)friendName
                                       eid:(NSString *)eid
                                 eventName:(NSString *)eventName
                              eventPicture:(NSString *)eventPicture
                            eventStartTime:(NSNumber *)eventStartTime {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification"
                                              inManagedObjectContext:context];
    
    Notification *notification = [[Notification alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    notification.type = type;
    notification.time = time;
    notification.friendId = friendId;
    notification.friendName = friendName;
    notification.eid = eid;
    notification.eventName = eventName;
    notification.eventPicture = eventPicture;
    notification.eventStartTime = eventStartTime;
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error adding notification - error:%@", error);
    
    return notification;
}

@end
