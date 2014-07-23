//
//  FriendToEventCoreData.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"
#import "Event.h"

@interface FriendToEventCoreData : NSObject

+ (void) addFriendToEventPair:(Event *)event :(Friend *)friend;
+ (BOOL) isFriendToEventPairExist:(NSString *)eid :(NSString *)uid;

@end
