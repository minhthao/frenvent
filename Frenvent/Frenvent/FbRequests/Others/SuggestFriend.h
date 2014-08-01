//
//  SuggestFriend.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/31/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuggestFriend : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic) int numMutualFriends;

@end
