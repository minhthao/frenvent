//
//  NotificationGroup.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/8/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"
#import "Event.h"

@interface NotificationGroup : NSObject

@property (nonatomic, strong) Friend *friend;
@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic) int64_t time;

@end
