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
#import "TimeSupport.h"
#import "Event.h"
#import "Friend.h"

@implementation NotificationManager

/**
 * Create and display new invited notification
 * @param notification
 */
+ (void)createAndDisplayNewInvitedNotification:(Notification *)notification {
    if (notification.event != nil) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [[NSDate alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"You got invited to event: %@", notification.event.name];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

/**
 * Create and display new friend notification
 * @param notification
 */
+ (void)createAndDisplayNewFriendNotification:(Notification *)notification {
    if (notification.event != nil && [notification.friends count] > 0) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [[NSDate alloc] init];
        if ([notification.friends count] == 1)
            localNotification.alertBody = [NSString stringWithFormat:@"%@ replied interested to event: %@", ((Friend *)[notification.friends objectAtIndex:0]).name,  notification.event.name];
        else if ([notification.friends count] == 2)
            localNotification.alertBody = [NSString stringWithFormat:@"%@ and %@ replied interested to event: %@", ((Friend *)[notification.friends objectAtIndex:0]).name, ((Friend *)[notification.friends objectAtIndex:1]).name, notification.event.name];
        else
            localNotification.alertBody = [NSString stringWithFormat:@"%@, %@, and %d others replied interested to event: %@", ((Friend *)[notification.friends objectAtIndex:0]).name, ((Friend *)[notification.friends objectAtIndex:1]).name, (int16_t)([notification.friends count] - 2),  notification.event.name];
        
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

@end
