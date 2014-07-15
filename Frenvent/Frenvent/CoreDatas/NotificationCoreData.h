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
+ (NSArray *) getNotifications:(NSPredicate *)predicates;
+ (NSArray *) getNotificationsSince:(int64_t)sinceTime;
+ (NSArray *) getNotificationsSince:(int64_t)sinceTime ofType:(NSInteger)type;

+ (void) removeAllNotifications;
+ (Notification *) addNewInvitedNotification:(Event *)event;
+ (Notification *) addNewNotificationForEvent:(Event *)event andFriend:(Friend *)friend;


@end
