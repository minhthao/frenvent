//
//  FriendRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendsRequestDelegate <NSObject>
@optional
- (void)notifyFriendsQueryCompleted;
@end

@interface FriendsRequest : NSObject

@property (nonatomic, weak) id <FriendsRequestDelegate> delegate;
- (void) initFriends;

@end
