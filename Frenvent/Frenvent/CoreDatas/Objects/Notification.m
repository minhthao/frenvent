//
//  Notification.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/13/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "Notification.h"
#import "Event.h"
#import "Friend.h"

NSInteger const TYPE_NEW_INVITE = 9;
NSInteger const TYPE_FRIEND_EVENT = 5;

@implementation Notification

@dynamic time;
@dynamic type;
@dynamic event;
@dynamic friends;

@end
