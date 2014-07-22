//
//  FriendInfo.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/20/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FbUserInfo : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSArray *ongoingEvents;
@property (nonatomic, strong) NSArray *pastEvents;
@property (nonatomic, strong) NSArray *mutualFriends;
@property (nonatomic, strong) NSArray *recommendedPeople;

@end
