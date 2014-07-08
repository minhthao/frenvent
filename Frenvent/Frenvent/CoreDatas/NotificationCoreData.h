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
+ (Notification *) addNotification:(NSNumber *)type
                                  :(NSNumber *)time
                                  :(NSString *)friendId
                                  :(NSString *)friendName
                                  :(NSString *)eid
                                  :(NSString *)eventName
                                  :(NSString *)eventPicture
                                  :(NSNumber *)eventStartTime;

@end
