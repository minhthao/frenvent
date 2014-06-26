//
//  Event.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/26/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendInterested;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eid;
@property (nonatomic, retain) NSNumber * endTime;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numInterested;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * privacy;
@property (nonatomic, retain) NSString * rsvp;
@property (nonatomic, retain) NSNumber * startTime;
@property (nonatomic, retain) NSSet *friendsInterested;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addFriendsInterestedObject:(FriendInterested *)value;
- (void)removeFriendsInterestedObject:(FriendInterested *)value;
- (void)addFriendsInterested:(NSSet *)values;
- (void)removeFriendsInterested:(NSSet *)values;

@end
