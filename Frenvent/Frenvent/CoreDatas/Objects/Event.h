//
//  Event.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/26/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendToEvent;

extern NSString * const RSVP_ATTENDING;
extern NSString * const RSVP_UNSURE;
extern NSString * const RSVP_DECLINED;
extern NSString * const RSVP_NOT_REPLIED;
extern NSString * const RSVP_NOT_INVITED;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eid;
@property (nonatomic) int64_t endTime;
@property (nonatomic, retain) NSString * host;
@property (nonatomic) double latitude;
@property (nonatomic, retain) NSString * location;
@property (nonatomic) double longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t numInterested;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * privacy;
@property (nonatomic, retain) NSString * rsvp;
@property (nonatomic) int64_t startTime;
@property (nonatomic, retain) NSSet *friendsInterested;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addFriendsInterestedObject:(FriendToEvent *)value;
- (void)removeFriendsInterestedObject:(FriendToEvent *)value;
- (void)addFriendsInterested:(NSSet *)values;
- (void)removeFriendsInterested:(NSSet *)values;

@end
