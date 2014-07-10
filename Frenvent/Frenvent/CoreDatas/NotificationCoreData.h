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
+ (Notification *) addNotificationWithType:(NSNumber *)type
                          notificationTime:(NSNumber *)time
                                  friendId:(NSString *)friendId
                                friendName:(NSString *)friendName
                                       eid:(NSString *)eid
                                 eventName:(NSString *)eventName
                              eventPicture:(NSString *)eventPicture
                            eventStartTime:(NSNumber *)eventStartTime;

@end
