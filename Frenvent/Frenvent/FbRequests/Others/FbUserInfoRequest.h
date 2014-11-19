//
//  FriendInfoRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuggestFriend.h"
#import "FbUserInfo.h"

@protocol FbUserInfoRequestDelegate <NSObject>
@required
- (void)fbUserInfoRequestResult:(FbUserInfo *)userInfo;
@end

@interface FbUserInfoRequest : NSObject

@property (nonatomic, weak) id <FbUserInfoRequestDelegate> delegate;

- (void)queryFbUserInfo:(NSString *)uid;

@end
