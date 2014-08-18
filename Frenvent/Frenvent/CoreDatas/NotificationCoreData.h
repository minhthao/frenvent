//
//  NotificationCoreData.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/3/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"

@interface NotificationCoreData : NSObject
+ (NSArray *) getNotifications;

+ (void) removeAllNotifications;
+ (void)removeNotification:(Notification *)notification;
+ (Notification *) addNotificationForEvent:(Event *)event andFriend:(Friend *)friend;
+ (Notification *) addNotificationForEvent:(Event *)event andFriend:(Friend *)friend andTime:(NSNumber *)time;


@end
