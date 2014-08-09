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

//here we get the events that are not hidden
+ (NSArray *) getEvents:(NSPredicate *)predicates sortByDateAsc:(BOOL)isAsc;
+ (NSArray *) getUserPastEvents;
+ (NSArray *) getUserOngoingEvents;
+ (NSArray *) getUserRepliedOngoingEvents;
+ (NSArray *) getUserUnrepliedOngoingEvents;
+ (NSArray *) getNearbyEventsBoundedByLowerLongitude:(double)lowerLongitude
                                       lowerLatitude:(double)lowerLatitude
                                      upperLongitude:(double)upperLongitude
                                       upperLatitude:(double)upperLatitude;
+ (NSArray *) getNearbyEventsBoundedByLowerLongitude:(double)lowerLongitude
                                       lowerLatitude:(double)lowerLatitude
                                      upperLongitude:(double)upperLongitude
                                       upperLatitude:(double)upperLatitude
                                      lowerTimeBound:(int64_t)lowerTimeBound
                                      upperTimeBound:(int64_t)upperTimeBound;

+ (NSArray *) getFriendsEvents;

//for these three, we don't need to hide the hidden one
+ (NSArray *) getAllOngoingEvents;
+ (NSArray *) getTodayEvents;
+ (NSArray *) getEventsWithMatchingName:(NSString *)name;
+ (Event *) getEventWithEid:(NSString *)eid;

//and finally we get either of type hidden or type favorite
+ (NSArray *) getOngoingHiddenEvents;
+ (NSArray *) getOngoingFavoriteEvents;
+ (NSArray *) getPastFavoriteEvents;
+ (void) setEventMarkType:(Event *)event withType:(int32_t)markType;

+ (void) removeAllEvents;
+ (void) removeUserAssociatedEvents;
+ (void) removeEventWithEid:(NSString *)eid;

+ (Event *) addEventUsingEid:(NSString *)eid
                        name:(NSString *)name
                     picture:(NSString *)picture
                       cover:(NSString *)cover
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
+ (void) checkEventCover:(Event *)event :(NSDictionary *)eventObj;
@end
