//
//  NotificationManager.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/14/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"

@interface NotificationManager : NSObject

+ (void)createAndDisplayNewInvitedNotification:(Notification *)notification;
+ (void)createAndDisplayNewFriendNotification:(Notification *)notification;

@end
