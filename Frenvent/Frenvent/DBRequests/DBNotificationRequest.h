//
//  DBNotificationRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBNotificationRequestDelegate <NSObject>
- (void)notifyNotificationComplete;
@end

@interface DBNotificationRequest : NSObject

@property (nonatomic, weak) id<DBNotificationRequestDelegate> delegate;

+ (BOOL)addNotificationForFriend:(NSString *)uid andEvent:(NSString *)eid andStartTime:(int64_t)startTime;
- (void)getNotifications;

@end
