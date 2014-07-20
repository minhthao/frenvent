//
//  EventParticipant.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"

@interface EventParticipant : NSObject

@property (nonatomic, strong) NSString *rsvpStatus;
@property (nonatomic, strong) Friend *friend;

@end
