//
//  FriendToEventCoreData.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/26/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Friend.h"

@interface FriendToEventCoreData : NSObject

//this add class is special, when adding the FriendToEvent pair,
//The object Event and Friend must be change to reflect this as well
+ (void) addFriendToEventPair:(Event *)event :(Friend *)friend;
+ (BOOL) isFriendToEventPairExist:(NSString *)eid :(NSString *)uid;
+ (NSArray *) getAllFutureEventsPertainingToUser:(NSString *)uid;
+ (NSArray *) getAllPastEventsPertainingToUser:(NSString *)uid;
+ (void) removeAllFriendToEventPairs;
+ (void) removeAllFriendToEventPairsAssociateWithEvent:(NSString *)eid;


@end
