//
//  EventDetail.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventDetail : NSObject

@property (nonatomic, strong) NSString * eid;
@property (nonatomic, strong) NSString * rsvp;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * picture;
@property (nonatomic, strong) NSString * cover;
@property (nonatomic) int64_t startTime;
@property (nonatomic) int64_t endTime;
@property (nonatomic, strong) NSString * location;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * zip;
@property (nonatomic, strong) NSString * country;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic, strong) NSString * description;
@property (nonatomic) int32_t attendingCount;
@property (nonatomic) int32_t unsureCount;
@property (nonatomic) int32_t unrepliedCountl;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSString * privacy;
@property (nonatomic, strong) NSArray * attendingFriends;

- (NSString *) getEventDisplayTime;

@end
