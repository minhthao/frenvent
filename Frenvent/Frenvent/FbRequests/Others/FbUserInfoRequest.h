//
//  FriendInfoRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FbUserInfo.h"
#import "Friend.h"

@protocol FbUserInfoRequestDelegate <NSObject>
@required
- (void)notifyFbUserInfoRequestFail;
- (void)notifyFbUserInfoRequestCompletedWithResult:(FbUserInfo *)FbUserInfo;
@end

@interface FbUserInfoRequest : NSObject

@property (nonatomic, weak) id <FbUserInfoRequestDelegate> delegate;

- (void)queryFriendInfo:(Friend *)friend;

@end
