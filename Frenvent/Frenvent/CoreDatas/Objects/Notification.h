//
//  Notification.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/8/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Friend;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Friend *friend;

@end
