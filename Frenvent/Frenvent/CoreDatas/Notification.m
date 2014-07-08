//
//  Notification.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "Notification.h"

NSInteger const TYPE_NEW_INVITE = 9;
NSInteger const TYPE_FRIEND_EVENT = 5;

@implementation Notification

@dynamic type;
@dynamic time;
@dynamic eid;
@dynamic eventName;
@dynamic eventStartTime;
@dynamic eventPicture;
@dynamic friendName;
@dynamic friendId;

@end
