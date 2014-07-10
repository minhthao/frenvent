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

+ (NSArray *) getEvents:(NSPredicate *)predicates;
+ (NSArray *) getUserPastEvents;
+ (NSArray *) getUserOngoingEvents;
+ (NSArray *) getUserRsvpOngoingEvents;
+ (NSArray *) getUserUnrepliedOngoingEvents;
+ (NSArray *) getNearbyEventsBoundedByLowerLongitude:(double)lowerLongitude
                                       lowerLatitude:(double)lowerLatitude
                                      upperLongitude:(double)upperLongitude
                                       upperLatitude:(double)upperLatitude;
+ (NSArray *) getFriendsEvents;
+ (NSArray *) getEventsWithMatchingName:(NSString *)name;
+ (Event *) getEventWithEid:(NSString *)eid;

+ (void) removeAllEvents;
+ (void) removeUserAssociatedEvents;
+ (void) removeEventWithEid:(NSString *)eid;

+ (Event *) addEventUsingEid:(NSString *)eid
                        name:(NSString *)name
                     picture:(NSString *)picture
                   startTime:(int64_t)startTime
                     endTime:(int64_t)endTime
                    location:(NSString *)location
                   longitude:(double)longitude
                    latitude:(double)latitude
                        host:(NSString *)host
                     privacy:(NSString *)privacy
               numInterested:(int32_t)numInterested
                        rsvp:(NSString *)rsvp;
+ (Event *) addEvent:(NSDictionary *)eventObj usingRsvp:(NSString *)rsvp;

+ (void) updateEventWithEid:(NSString *)eid usingRsvp:(NSString *)newRsvp; //Still todo the notification callback
@end
