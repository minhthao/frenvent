//
//  NotificationManager.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/14/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "NotificationManager.h"
#import "NotificationCoreData.h"
#import "Notification.h"

@implementation NotificationManager

+ (void)displayInvitedEventNotifications:(int64_t)sinceTime {
    NSArray *myNotifications = [NotificationCoreData getNotificationsSince:sinceTime ofType:TYPE_NEW_INVITE];
    if (myNotifications != nil && [myNotifications count] > 0) {}
        //[NotificationManager displayInvitedEventNotifications:myNotifications];
}
@end
