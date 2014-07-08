//
//  Notification.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSInteger const TYPE_NEW_INVITE;
extern NSInteger const TYPE_FRIEND_EVENT;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSString * eid;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSNumber * eventStartTime;
@property (nonatomic, retain) NSString * eventPicture;
@property (nonatomic, retain) NSString * friendName;
@property (nonatomic, retain) NSString * friendId;

@end
