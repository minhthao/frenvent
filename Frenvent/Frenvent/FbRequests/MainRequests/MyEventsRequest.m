//
//  MyEventsRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "MyEventsRequest.h"
#import "TimeSupport.h"
#import "EventCoreData.h"
#import "NotificationCoreData.h"
#import "Notification.h"
#import "TimeSupport.h"
#import "Event.h"

static NSInteger const QUERY_LIMIT = 400;
static NSInteger const QUERY_TYPE_INITIALIZE = 0;
static NSInteger const QUERY_TYPE_REFRESH = 1;
static NSInteger const QUERY_TYPE_BACKGROUND_SERVICE = 2;

@interface MyEventsRequest()
- (NSDictionary *) prepareAllEventsQueryParams;
- (NSDictionary *) prepareFutureEventsQueryParams;
- (void) executeQueryWithType: (NSInteger)type;
- (void) handleNewEventInvited:(Event *)event;
@end

@implementation MyEventsRequest

#pragma mark - private methods
/**
 * prepare the query for all of my events method's parameters
 * @return dictionary
 */
- (NSDictionary *) prepareAllEventsQueryParams {
    int64_t todayTime = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    NSString *myEvents = [NSString stringWithFormat:@"SELECT eid, rsvp_status FROM event_member WHERE uid = me() "
                          "AND (((rsvp_status = \"attending\" OR rsvp_status = \"unsure\") AND start_time < %lld) OR start_time >= %lld) "
                          "ORDER BY start_time DESC LIMIT %d", todayTime, todayTime, QUERY_LIMIT];
    NSString *eventInfo = [NSString stringWithFormat:@"SELECT eid, name, pic_big, start_time, end_time, "
                           "location, venue, unsure_count, attending_count, privacy, host FROM event "
                           "WHERE eid IN (SELECT eid from #myEvents) "
                           "ORDER BY start_time DESC LIMIT %d", QUERY_LIMIT];
    
    NSString *query = [NSString stringWithFormat:@"{'myEvents':'%@', 'eventInfo':'%@'}",
                       myEvents, eventInfo];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

/**
 * Prepare the query for all of my future events method's parameters
 * @return dictionary
 */
- (NSDictionary *) prepareFutureEventsQueryParams {
    int64_t todayTime = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    NSString *myEvents = [NSString stringWithFormat:@"SELECT eid, rsvp_status FROM event_member WHERE uid = me() "
                          "AND start_time >= %lld ORDER BY start_time DESC LIMIT %d", todayTime, QUERY_LIMIT];
    NSString *eventInfo = [NSString stringWithFormat:@"SELECT eid, name, pic_big, start_time, end_time, "
                           "location, venue, unsure_count, attending_count, privacy, host FROM event "
                           "WHERE eid IN (SELECT eid from #myEvents) "
                           "ORDER BY start_time DESC LIMIT %d", QUERY_LIMIT];
    
    NSString *query = [NSString stringWithFormat:@"{'myEvents':'%@', 'eventInfo':'%@'}",
                       myEvents, eventInfo];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

/**
 * Execute the query with one of the 3 types: initialize, update, background
 * @param type
 */
- (void) executeQueryWithType:(NSInteger)type {
    NSDictionary *queryParams = [self prepareFutureEventsQueryParams];
    if (type == QUERY_TYPE_INITIALIZE) queryParams = [self prepareAllEventsQueryParams];
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParams
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
                              NSMutableDictionary *eventsDictionary =[[NSMutableDictionary alloc] init];
                              NSMutableDictionary *newEventsDictionary = [[NSMutableDictionary alloc] init];
                              
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSArray *data = (NSArray *)result[@"data"];
                                  NSArray *myEvents = nil;
                                  NSArray *eventInfo = nil;
                                  NSMutableDictionary *rsvpDictionary = [[NSMutableDictionary alloc] init];
                                  
                                  //get approprivate info arrays
                                  for (int i = 0; i < [data count]; i++) {
                                      if ([data[i][@"name"] isEqualToString:@"myEvents"])
                                          myEvents = data[i][@"fql_result_set"];
                                      if ([data[i][@"name"] isEqualToString:@"eventInfo"])
                                          eventInfo = data[i][@"fql_result_set"];
                                  }
                                  
                                  //get the rsvp for each event
                                  for (int i = 0; i < [myEvents count]; i++) {
                                      NSString *eid = [myEvents[i][@"eid"] stringValue];
                                      NSString *rsvp = myEvents[i][@"rsvp_status"];
                                      [rsvpDictionary setObject:rsvp forKey:eid];
                                  }
                                  
                                  //add events to the core data, or change the rsvp if necessary
                                  for (int i = 0; i < [eventInfo count]; i++) {
                                      NSString *eid = [eventInfo[i][@"eid"] stringValue];
                                      Event *event = [EventCoreData getEventWithEid:eid];
                                      if (event == nil) {
                                          event = [EventCoreData addEvent:eventInfo[i] :rsvpDictionary[eid]];
                                          [newEventsDictionary setObject:event forKey:event.eid];
                                          if (type == QUERY_TYPE_BACKGROUND_SERVICE)
                                              [self handleNewEventInvited:event];
                                      } else {
                                          if (![event.rsvp isEqualToString:rsvpDictionary[eid]]) {
                                              if ([event.rsvp isEqualToString:RSVP_NOT_INVITED] && type == QUERY_TYPE_BACKGROUND_SERVICE)
                                                  [self handleNewEventInvited:event];
                                              event.rsvp = rsvpDictionary[eid];
                                              [EventCoreData updateEventRsvp:eid :rsvpDictionary[eid]];
                                          }
                                      }
                                      [eventsDictionary setObject:event forKey:event.eid];
                                  }
                              }
                              
                              if (type == QUERY_TYPE_INITIALIZE || type == QUERY_TYPE_REFRESH)
                                  [self.delegate notifyMyEventsQueryCompletedWithResult:[eventsDictionary allValues] :newEventsDictionary];
                          }];
}

#pragma mark -TODO taken away when done
/**
 * Handle when the new you get invited to the new event
 * @param Event
 * @param Friend
 */
- (void) handleNewEventInvited:(Event *)event {
    [NotificationCoreData addNotification:TYPE_NEW_INVITE :[TimeSupport getCurrentTimeInUnix] :@"" :@"" :event.eid :event.name :event.picture :event.startTime :false];
}

#pragma mark - public methods
/**
 * Init and stored in the core data all the my events.
 * Do this when the user first login.
 */
- (void) initMyEvents {
    [self executeQueryWithType:QUERY_TYPE_INITIALIZE];
}

/**
 * Call when the user request to refresh my events
 */
- (void) refreshMyEvents {
    [self executeQueryWithType:QUERY_TYPE_REFRESH];
}

/**
 * Call when prepare for push notifications in the background
 */
- (void) updateBackgroundMyEvents {
    [self executeQueryWithType:QUERY_TYPE_BACKGROUND_SERVICE];
}



@end
