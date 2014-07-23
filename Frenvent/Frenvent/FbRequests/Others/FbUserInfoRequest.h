//
//  FriendInfoRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"

@protocol FbUserInfoRequestDelegate <NSObject>
@required
- (void)notifyFbUserInfoRequestFail;
@optional
- (void)fbUserInfoRequestName:(NSString *)name;
- (void)fbUserInfoRequestProfileCover:(NSString *)cover;
- (void)fbUserInfoRequestOngoingEvents:(NSArray *)onGoingEvents;
- (void)fbUserInfoRequestPastEvents:(NSArray *)pastEvents;
- (void)fbUserInfoRequestMutualFriends:(NSArray *)mutualFriends;
@end

@interface FbUserInfoRequest : NSObject

@property (nonatomic, weak) id <FbUserInfoRequestDelegate> delegate;

- (void)queryFbUserInfo:(NSString *)uid;

@end
