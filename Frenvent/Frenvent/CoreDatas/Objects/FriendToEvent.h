//
//  FriendInterested.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/26/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Friend;

@interface FriendInterested : NSManagedObject

@property (nonatomic, retain) NSString * eid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * startTime;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Friend *friend;

@end
