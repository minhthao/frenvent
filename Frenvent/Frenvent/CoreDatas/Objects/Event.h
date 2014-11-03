//
//  Event.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/14/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend, Notification;

extern NSString * const RSVP_ATTENDING;
extern NSString * const RSVP_UNSURE;
extern NSString * const RSVP_DECLINED;
extern NSString * const RSVP_NOT_REPLIED;
extern NSString * const RSVP_NOT_INVITED;

extern NSString * const PRIVACY_OPEN;
extern NSString * const PRIVACY_FRIENDS;
extern NSString * const PRIVACY_SECRET;

extern int32_t const MARK_TYPE_NORMAL;
extern int32_t const MARK_TYPE_FAVORITE;
extern int32_t const MARK_TYPE_HIDDEN;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * cover;
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
@property (nonatomic, retain) NSNumber * markType;
@property (nonatomic, retain) NSSet *friendsInterested;
@property (nonatomic, retain) NSSet *notifications;

@property (nonatomic, strong) NSNumber * distance;
@property (nonatomic) double score;

- (BOOL)canRsvp;
- (BOOL)canShare;
- (void)computeDistanceToCurrentLocation:(CLLocation *)currentLocation;

// get the display attributed string
- (NSAttributedString *)getFriendsInterestedAttributedString;
- (NSAttributedString *)getRsvpAttributedString;
- (NSAttributedString *)getRsvpAndAttendeesAttributedString;
- (NSAttributedString *)getHostAttributedString;
- (NSAttributedString *)getFromEventNameAttributedString;
- (NSString *)getDistanceString;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addFriendsInterestedObject:(Friend *)value;
- (void)removeFriendsInterestedObject:(Friend *)value;
- (void)addFriendsInterested:(NSSet *)values;
- (void)removeFriendsInterested:(NSSet *)values;

- (void)addNotificationsObject:(Notification *)value;
- (void)removeNotificationsObject:(Notification *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

@end
