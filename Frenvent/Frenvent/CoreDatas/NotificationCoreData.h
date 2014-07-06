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
+ (Notification *) addNotification:(int16_t)type
                                  :(int64_t)time
                                  :(NSString *)friendId
                                  :(NSString *)friendName
                                  :(NSString *)eid
                                  :(NSString *)eventName
                                  :(NSString *)eventPicture
                                  :(int64_t)eventStartTime
                                  :(BOOL)viewed;

+ (void) updateNotificationView:(Notification *)notification; //Still todo the notification callback

@end
