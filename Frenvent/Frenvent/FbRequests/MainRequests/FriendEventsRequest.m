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
#import "NotificationManager.h"

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
- (NSDictionary *) prepareQueryParams:(NSArray *)friendSubArray {
    
    NSMutableString *friendsUidString = [[NSMutableString alloc] init];
    
    for (NSInteger i = 0; i < friendSubArray.count; i++) {
        
        if (i != friendSubArray.count - 1)
            [friendsUidString appendFormat:@"uid = \"%@\" OR ", ((Friend *)[friendSubArray objectAtIndex:i]).uid];
        else [friendsUidString appendFormat:@"uid = \"%@\"", ((Friend *)[friendSubArray objectAtIndex:i]).uid];
    }
    
    NSString *friendEvents = [NSString stringWithFormat:@"SELECT eid, uid, rsvp_status FROM event_member WHERE "
                               "(rsvp_status = \"attending\" OR rsvp_status = \"unsure\") "  //rsvp
                               "AND (%@) " //all of my friends events
                               "AND start_time >= %lld " //future
                               "ORDER BY start_time ASC LIMIT %d",
                               friendsUidString, [TimeSupport getTodayTimeFrameStartTimeInUnix], QUERY_LIMIT];
    
    NSString *friendNames = [NSString stringWithFormat:@"SELECT uid, name FROM user WHERE uid IN "
                             "(SELECT uid FROM #friendEvents) LIMIT %d", QUERY_LIMIT];

    NSString *eventInfo = [NSString stringWithFormat:@"SELECT eid, name, pic_big, pic_cover, start_time, end_time, "
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
 * @param completion handler for the background fetch
 */
- (void) executeQueryWithType:(NSInteger)type withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSArray *friendSubarrays = [self splitArrayWithArray:[FriendCoreData getAllFriends] rangeNumber:20];
    
    for (NSInteger i = 0; i < friendSubarrays.count; i++) {
        NSDictionary *queryParams = [self prepareQueryParams:[friendSubarrays objectAtIndex:i]];
        
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:queryParams
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  
                                  NSMutableDictionary *eventsDictionary =[[NSMutableDictionary alloc] init];
                                  NSMutableDictionary *friendsDictionary = [[NSMutableDictionary alloc] init];
                                  NSMutableDictionary *newEventsDictionary = [[NSMutableDictionary alloc] init];
                                  
                                  if (error && (i == friendSubarrays.count - 1)) {
                                        [self.delegate notifyFriendEventsQueryEncounterError:completionHandler];
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
                                          NSString *eid = [NSString stringWithFormat:@"%@", eventInfo[i][@"eid"]];
                                          Event *event = [EventCoreData getEventWithEid:eid];
                                          if (event == nil) {
                                              event = [EventCoreData addEvent:eventInfo[i] usingRsvp:RSVP_NOT_INVITED];
                                              [newEventsDictionary setObject:event forKey:eid];
                                          } else [EventCoreData checkEventCover:event :eventInfo[i]];
                                          
                                          [eventsDictionary setObject:event forKey:eid];
                                      }
                                      
                                      //we then add the friends to the core data
                                      for (NSDictionary *friendName in friendNames) {
                                          NSString *uid = [NSString stringWithFormat:@"%@", friendName[@"uid"]];
                                          NSString *name = friendName[@"name"];
                                          Friend *friend = [FriendCoreData getFriendWithUid:uid];
                                          if (friend == nil)
                                              friend = [FriendCoreData addFriend:uid :name];
                                          
                                          [friendsDictionary setObject:friend forKey:friend.uid];
                                      }
                                      
                                      //Finally, we add in the friend to events pairs
                                      for (NSDictionary *friendEvent in friendEvents) {
                                          NSString *uid = [NSString stringWithFormat:@"%@", friendEvent[@"uid"]];
                                          NSString *eid = [NSString stringWithFormat:@"%@", friendEvent[@"eid"]];
                                          
                                          if (![FriendToEventCoreData isFriendToEventPairExist:eid :uid]) {
                                              Event *event = eventsDictionary[eid];
                                              Friend *friend = friendsDictionary[uid];
                                              if (event != nil && friend != nil) {
                                                  [FriendToEventCoreData addFriendToEventPair:event :friend];
                                                  if (type != QUERY_TYPE_INITIALIZE) {
                                                      Notification *notification = [NotificationCoreData addNotificationForEvent:event andFriend:friend];
                                                      [NotificationManager createNewFriendNotification:notification];
                                                  }
                                              }
                                          }
                                      }
                                      
                                      if (i == friendSubarrays.count - 1) {
                                          if (type == QUERY_TYPE_INITIALIZE || type == QUERY_TYPE_REFRESH)
                                              [self.delegate notifyFriendEventsQueryCompletedWithResult:[eventsDictionary allValues] :newEventsDictionary];
                                          else [self.delegate notifyFriendEventsUpdateCompletedWithNewEvents:[newEventsDictionary allValues] usingCompletionHandler:completionHandler];
                                      }
                                  }
                              }];

    }
}


/**
 * function that will split an array of object into smaller subarray with a maximum cap number
 * @param raw array
 * @param range number
 * @return new array
 */
- (NSArray*) splitArrayWithArray:(NSArray*)rawArray rangeNumber:(int)rangeNumber{
    NSInteger totalCount = rawArray.count;
    NSInteger currentIndex = 0;
    
    NSMutableArray* splitArray = [NSMutableArray array];
    
    while (currentIndex < totalCount) {
        NSRange range = NSMakeRange(currentIndex, MIN(rangeNumber, totalCount-currentIndex));
        NSArray* subArray = [rawArray subarrayWithRange:range];
        [splitArray addObject:subArray];
        currentIndex += rangeNumber;
    }
    return splitArray;
}

#pragma mark - public methods
/**
 * Init and stored in the core data all the user's friend events.
 * Do this when the user first login.
 */
- (void) initFriendEvents {
    if ([FBSession activeSession].isOpen && [[FBSession activeSession] hasGranted:@"friends_events"])
        [self executeQueryWithType:QUERY_TYPE_INITIALIZE withCompletionHandler:nil];
    else if ([FBSession activeSession].state== FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                            allowLoginUI:NO
                                       completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                           
            if (error) [self.delegate notifyFriendEventsQueryEncounterError:nil];
            else if (FB_ISSESSIONOPENWITHSTATE(status)) [self executeQueryWithType:QUERY_TYPE_REFRESH withCompletionHandler:nil];
            else [self.delegate notifyFriendEventsQueryEncounterError:nil];
        }];
    } else [self.delegate notifyFriendEventsQueryEncounterError:nil];
}

/**
 * Call when the user request to refresh the friend events
 */
- (void) refreshFriendEvents {
    if ([FBSession activeSession].isOpen && [[FBSession activeSession] hasGranted:@"friends_events"]) {
        [self executeQueryWithType:QUERY_TYPE_REFRESH withCompletionHandler:nil];
    }else if ([FBSession activeSession].state== FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) [self.delegate notifyFriendEventsQueryEncounterError:nil];
            else if (FB_ISSESSIONOPENWITHSTATE(status)) [self executeQueryWithType:QUERY_TYPE_REFRESH withCompletionHandler:nil];
            else [self.delegate notifyFriendEventsQueryEncounterError:nil];
        }];
    } else [self.delegate notifyFriendEventsQueryEncounterError:nil];
}

/**
 * Call when prepare for push notification (for friend events) in the background
 * @param completion handler for the background fetch
 */
- (void) updateBackgroundFriendEventsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([FBSession activeSession].isOpen && [[FBSession activeSession] hasGranted:@"friends_events"])
        [self executeQueryWithType:QUERY_TYPE_BACKGROUND_SERVICE withCompletionHandler:completionHandler];
    else if ([FBSession activeSession].state== FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) [self.delegate notifyFriendEventsQueryEncounterError:completionHandler];
            else if (FB_ISSESSIONOPENWITHSTATE(status)) [self executeQueryWithType:QUERY_TYPE_BACKGROUND_SERVICE withCompletionHandler:completionHandler];
            else [self.delegate notifyFriendEventsQueryEncounterError:completionHandler];
        }];
    } else [self.delegate notifyFriendEventsQueryEncounterError:completionHandler];
}
@end
