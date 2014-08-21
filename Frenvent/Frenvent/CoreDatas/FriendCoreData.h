//
//  FriendCoreData.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/26/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"

@interface FriendCoreData : NSObject

+ (Friend *) addFriend:(NSString *)uid :(NSString *)name;
+ (Friend *) addFriend:(NSString *)uid :(NSString *)name :(NSString *)cover;
+ (Friend *) getFriendWithUid:(NSString *)uid;
+ (NSArray *) getAllFriends;
+ (NSArray *) getAllFutureEventsPertainingToUser:(NSString *)uid;
+ (NSArray *) getAllPastEventsPertainingToUser:(NSString *)uid;
+ (void) markFriend:(Friend *)friend;
+ (void) setFriend:(Friend *)friend toFavorite:(BOOL)favorite;
+ (void) updateFriendCover:(Friend *)friend :(NSString *)cover;
+ (void) removeAllFriends;

@end
