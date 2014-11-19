//
//  FbUserInfo.h
//  Frenvent
//
//  Created by minh thao nguyen on 11/10/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FbUserInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSArray *recommendFriends;
@property (nonatomic, strong) NSArray *events;

@end
