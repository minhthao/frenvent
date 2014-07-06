//
//  Notification.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/3/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern int16_t const TYPE_NEW_INVITE;
extern int16_t const TYPE_FRIEND_EVENT;

@interface Notification : NSManagedObject

@property (nonatomic) int16_t type;
@property (nonatomic) int64_t time;
@property (nonatomic) BOOL viewed;
@property (nonatomic, retain) NSString * eid;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic) int64_t eventStartTime;
@property (nonatomic, retain) NSString * eventPicture;
@property (nonatomic, retain) NSString * friendName;
@property (nonatomic, retain) NSString * friendId;

@end
