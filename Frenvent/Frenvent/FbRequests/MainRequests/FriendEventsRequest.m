//
//  FriendEventsRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/28/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendEventsRequest.h"
#import "TimeSupport.h"
#import "EventCoreData.h"
#import "FriendCoreData.h"
#import "NotificationCoreData.h"
#import "FriendToEventCoreData.h"

static int16_t const QUERY_LIMIT = 5000;
static int16_t const QUERY_TYPE_INITIALIZE = 0;
static int16_t const QUERY_TYPE_REFRESH = 1;
static int16_t const QUERY_TYPE_BACKGROUND_SERVICE = 2;

@implementation FriendEventsRequest

#pragma mark - private methods
/**
 * Prepare the query method parameters
 * @return dictionary
 */
- (NSDictionary *) prepareQueryParams {
    NSString *friendEvents = [NSString stringWithFormat:@"SELECT eid, uid FROM event_member WHERE "
                               "(rsvp_status = \"attending\" OR rsvp_status = \"unsure\") "  //rsvp
                               "AND uid IN (SELECT uid2 FROM friend WHERE uid1 = me() LIMIT %d) " //all of my friends events
                               "AND start_time >= %lld " //future
                               "ORDER BY start_time ASC LIMIT %d",
                               QUERY_LIMIT, [TimeSupport getTodayTimeFrameStartTimeInUnix], QUERY_LIMIT];
    
    NSString *friendNames = [NSString stringWithFormat:@"SELECT uid, name FROM user WHERE uid IN "
                             "(SELECT uid FROM #friendEvents) LIMIT %d", QUERY_LIMIT];
    
    NSString *eventInfo = [NSString stringWithFormat:@"SELECT eid, name, pic_big, start_time, end_time, "
                           "location, venue, unsure_count, attending_count, privacy, host FROM event "
                           "WHERE eid IN (SELECT eid from #friendEvents) "
                           "ORDER BY start_time ASC LIMIT %d",
                           QUERY_LIMIT];
    
    NSString *query = [NSString stringWithFormat:@"{'friendEvents':'%@', 'friendNames':'%@', 'eventInfo':'%@'}",
                       friendEvents, friendNames, eventInfo];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

/**
 * Execute the query with one of the 3 types: initialize, update, background
 * @param type
 */
- (void) executeQueryWithType:(NSInteger)type withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    int64_t currentTime = [TimeSupport getCurrentTimeInUnix];
    NSDictionary *queryParams = [self prepareQueryParams];
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParams
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
          NSMutableDictionary *eventsDictionary =[[NSMutableDictionary alloc] init];
          NSMutableDictionary *friendsDictionary = [[NSMutableDictionary alloc] init];
          NSMutableDictionary *newEventsDictionary = [[NSMutableDictionary alloc] init];
          
          if (error) {
              NSLog(@"Error: %@", [error localizedDescription]);
          } else {
              NSArray *data = (NSArray *)result[@"data"];
              NSArray *friendEvents = nil;
              NSArray *friendNames = nil;
              NSArray *eventInfo = nil;
              
              //get approprivate info arrays
              for (int i = 0; i < [data count]; i++) {
                  if ([data[i][@"name"] isEqualToString:@"friendEvents"])
                      friendEvents = data[i][@"fql_result_set"];
                  if ([data[i][@"name"] isEqualToString:@"friendNames"])
                      friendNames = data[i][@"fql_result_set"];
                  if ([data[i][@"name"] isEqualToString:@"eventInfo"])
                      eventInfo = data[i][@"fql_result_set"];
              }
              
              //we first add in the events to the core data
              for (int i = 0; i < [eventInfo count]; i++) {
                  NSString *eid = [eventInfo[i][@"eid"] stringValue];
                  Event *event = [EventCoreData getEventWithEid:eid];
                  if (event == nil) {
                      event = [EventCoreData addEvent:eventInfo[i] usingRsvp:RSVP_NOT_INVITED];
                      [newEventsDictionary setObject:event forKey:eid];
                  }
                  [eventsDictionary setObject:event forKey:eid];
              }
              
              //we then add the friends to the core data
              for (int j = 0; j < [friendNames count]; j++) {
                  NSString *uid = [friendNames[j][@"uid"] stringValue];
                  NSString *name = friendNames[j][@"name"];
                  Friend *friend = [FriendCoreData getFriendWithUid:uid];
                  if (friend == nil)
                      friend = [FriendCoreData addFriend:uid :name];
                  
                  [friendsDictionary setObject:friend forKey:friend.uid];
              }
              
              //Finally, we add in the friend to events pairs
              for (int i = 0; i < [friendEvents count]; i++) {
                  NSString *uid = [friendEvents[i][@"uid"] stringValue];
                  NSString *eid = [friendEvents[i][@"eid"] stringValue];
                  if (![FriendToEventCoreData isFriendToEventPairExist:eid :uid]) {
                      Event *event = eventsDictionary[eid];
                      Friend *friend = friendsDictionary[uid];
                      if (event != nil && friend != nil) {
                          [FriendToEventCoreData addFriendToEventPair:event :friend];
                          if (type != QUERY_TYPE_INITIALIZE)
                              [NotificationCoreData addNewNotificationForEvent:event andFriend:friend];
                      }
                  }
              }
          }
          
          if (type == QUERY_TYPE_INITIALIZE || type == QUERY_TYPE_REFRESH)
              [self.delegate notifyFriendEventsQueryCompletedWithResult:[eventsDictionary allValues] :newEventsDictionary];
          else [self.delegate notifyFriendEventsUpdateCompletedWithNewEvents:[newEventsDictionary allValues] usingCompletionHandler:completionHandler];
      }];

}

#pragma mark - public methods
/**
 * Init and stored in the core data all the user's friend events.
 * Do this when the user first login.
 */
- (void) initFriendEvents {
    [self executeQueryWithType:QUERY_TYPE_INITIALIZE withCompletionHandler:nil];
}

/**
 * Call when the user request to refresh the friend events
 */
- (void) refreshFriendEvents {
    [self executeQueryWithType:QUERY_TYPE_REFRESH withCompletionHandler:nil];
}

/**
 * Call when prepare for push notification (for friend events) in the background
 */
- (void) updateBackgroundFriendEventsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self executeQueryWithType:QUERY_TYPE_BACKGROUND_SERVICE withCompletionHandler:completionHandler];
}
@end
