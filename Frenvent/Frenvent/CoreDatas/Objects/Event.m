//
//  Event.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "Event.h"
#import "Friend.h"

NSString * const RSVP_ATTENDING = @"attending";
NSString * const RSVP_UNSURE = @"unsure";
NSString * const RSVP_DECLINED = @"declined";
NSString * const RSVP_NOT_REPLIED = @"not_replied";
NSString * const RSVP_NOT_INVITED = @"not_invited";

@implementation Event

@dynamic eid;
@dynamic endTime;
@dynamic host;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic name;
@dynamic numInterested;
@dynamic picture;
@dynamic privacy;
@dynamic rsvp;
@dynamic startTime;
@dynamic friendsInterested;

@end
