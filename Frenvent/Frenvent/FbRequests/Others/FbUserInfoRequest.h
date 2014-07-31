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
- (void)fbUserInfoRequestMutualFriendsCount:(int16_t)mutualFriendsCount;
- (void)fbUserInfoRequestPhotos:(NSArray *)urls;
- (void)fbUserInfoRequestOngoingEvents:(NSArray *)onGoingEvents;
- (void)fbUserInfoRequestPastEvents:(NSArray *)pastEvents;
@end

@interface FbUserInfoRequest : NSObject

@property (nonatomic, weak) id <FbUserInfoRequestDelegate> delegate;

- (void)queryFbUserInfo:(NSString *)uid;

@end
