//
//  NotificationManager.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/14/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject

+ (void)displayInvitedEventNotifications:(int64_t)sinceTime;
+ (void)displayFriendEventNotifications:(int64_t)sinceTime;

@end
