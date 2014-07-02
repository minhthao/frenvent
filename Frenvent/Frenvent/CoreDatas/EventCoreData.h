//
//  EventCoreData.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/24/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Friend.h"

@interface EventCoreData : NSObject

+ (NSArray *) getUserPastEvents;
+ (NSArray *) getUserOngoingEvents;
+ (NSArray *) getNearbyEvents:(double)lowerLongitude :(double)lowerLatitude
                             :(double)upperLongitude :(double)upperLatitude;
+ (NSArray *) getFriendsEvents;
+ (NSArray *) getEventsWithMatchingName:(NSString *)name;
+ (Event *) getEventWithEid:(NSString *)eid;

+ (void) removeAllEvents;
+ (void) removeUserAssociatedEvents;
+ (void) removeEventWithEid:(NSString *)eid;

+ (Event *) addEvent:(NSString *)eid
                 :(NSString *)name
                 :(NSString *)picture
                 :(int64_t)startTime
                 :(int64_t)endTime
                 :(NSString *)location
                 :(double)longitude
                 :(double)latitude
                 :(NSString *)host
                 :(NSString *)privacy
                 :(int32_t)numInterested
                 :(NSString *)rsvp;
+ (Event *) addEvent: (NSDictionary *)eventObj;

+ (void) updateEventRsvp:(NSString *)eid :(NSString *)newRsvp; //Still todo the notification callback
@end
