//
//  FriendInfoRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FbUserInfoRequest.h"
#import "FriendCoreData.h"
#import "Friend.h"
#import "EventCoreData.h"
#import "Event.h"
#import "FriendToEventCoreData.h"
#import "TimeSupport.h"

static int16_t const QUERY_LIMIT = 300;
static int64_t const LOWER_TIME_LIMIT = 1262304000;

@implementation FbUserInfoRequest

/**
 * Prepare the query method parameters
 * @return dictionary
 */
- (NSDictionary *) prepareCompleteInfoQueryParams:(NSString *)uid {
    NSString *userInfo = [NSString stringWithFormat:@"SELECT pic_cover FROM user WHERE uid = %@", uid];
    
    NSString *mutualFriends = [NSString stringWithFormat:@"SELECT uid, name FROM user WHERE uid IN "
                               "(SELECT uid2 FROM friend where uid2 IN (SELECT uid2 FROM friend WHERE uid1 = me()) "
                               "and uid1 = %@)", uid];
    
    NSString *events = [NSString stringWithFormat:@"SELECT eid FROM event_member WHERE uid = %@ AND "
                            "(rsvp_status = \"attending\" OR rsvp_status = \"unsure\") AND " //rsvp
                            "start_time > %lld ORDER BY start_time DES LIMIT %d",
                            uid, LOWER_TIME_LIMIT, QUERY_LIMIT];
    
    NSString *eventsInfo = [NSString stringWithFormat:@"SELECT eid, name, pic_big, start_name, end_time, "
                                "location, venue, attending_count, unsure_count, privacy, host FROM event "
                                "WHERE eid IN (SELECT eid FROM #events"];
    
    NSString *query = [NSString stringWithFormat:@"{'userInfo':'%@', 'mutualFriends':'%@', 'events':'%@', 'eventsInfo':'%@'}",
                       userInfo, mutualFriends, events, eventsInfo];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

/**
 * Prepare partial query method parameters
 * @return dictionary
 */
- (NSDictionary *) preparePartialInfoQueryParams:(NSString *)uid {
    NSString *userInfo = [NSString stringWithFormat:@"SELECT name, pic_cover FROM user WHERE uid = %@", uid];
    NSString *mutualFriends = [NSString stringWithFormat:@"SELECT uid, name FROM user WHERE uid IN "
                               "(SELECT uid2 FROM friend where uid2 IN (SELECT uid2 FROM friend WHERE uid1 = me()) "
                               "and uid1 = %@)", uid];
    
    NSString *query = [NSString stringWithFormat:@"{'userInfo':'%@', 'mutualFriends':'%@'}", userInfo, mutualFriends];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

/**
 * Execute the query for friend detail
 * @param friendd
 */
- (void) queryFriendInfo:(Friend *)friend{
    if ([FBSession activeSession].isOpen && [[FBSession activeSession] hasGranted:@"friends_events"])
        [self doQuery:friend];
    else if ([FBSession activeSession].state== FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          // if login fails for any reason, we alert
                                          if (error) {
                                              NSLog(@"error open session");
                                              [self.delegate notifyFbUserInfoRequestFail];
                                          } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                              [self doQuery:friend];
                                          } else [self.delegate notifyFbUserInfoRequestFail];
                                      }
         ];
    } else [self.delegate notifyFbUserInfoRequestFail];
}

- (void) doQuery:(Friend *) friend {
    FbUserInfo *fbUserInfo = [[FbUserInfo alloc] init];
    fbUserInfo.uid = friend.uid;
    fbUserInfo.name = friend.name;
    
    NSDictionary *queryParams = [self prepareCompleteInfoQueryParams:friend.uid];
    if ([friend.mark boolValue]) queryParams = [self preparePartialInfoQueryParams:friend.uid];
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParams
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                                  [self.delegate notifyFbUserInfoRequestFail];
                              } else {
                                  NSNull *nullInstance = [NSNull null];
                                  
                                  NSArray *data = (NSArray *)result[@"data"];
                                  
                                  for (int i = 0; i < [data count]; i++) {
                                      NSArray *resultSet = data[i][@"fql_result_set"];
                                      if ([data[i][@"name"] isEqualToString:@"userInfo"]) {
                                          if ([resultSet count] == 0) {
                                              [self.delegate notifyFbUserInfoRequestFail];
                                              return;
                                          } else {
                                              NSString *cover = @"";
                                              NSDictionary *infoObj = resultSet[0];
                                              if ([infoObj[@"pic_cover"] isKindOfClass:[NSDictionary class]]) {
                                                  NSDictionary *coverDic = infoObj[@"pic_cover"];
                                                  if (coverDic[@"source"] != nullInstance)
                                                      cover = coverDic[@"source"];
                                              }
                                              fbUserInfo.cover = cover;
                                          }
                                      } else if ([data[i][@"name"] isEqualToString:@"mutualFriends"]) {
                                          NSMutableArray *mutualFriends = [[NSMutableArray alloc] init];
                                          if ([resultSet count] > 0) {
                                              for (NSDictionary *mutualFriend in resultSet) {
                                                  Friend *friend = [FriendCoreData getFriendWithUid:mutualFriend[@"uid"]];
                                                  if (friend == nil)
                                                      friend = [FriendCoreData addFriend:mutualFriend[@"uid"] :mutualFriend[@"name"]];
                                                  [mutualFriends addObject:friend];
                                              }
                                          }
                                          fbUserInfo.mutualFriends =  mutualFriends;
                                      } else if ([data[i][@"name"] isEqualToString:@"eventsInfo"]) {
                                          if ([resultSet count] > 0) {
                                              for (NSDictionary *eventInfo in resultSet) {
                                                  NSString *eid = [eventInfo[@"eid"] stringValue];
                                                  Event *event = [EventCoreData getEventWithEid:eid];
                                                  if (event == nil)
                                                      event = [EventCoreData addEvent:eventInfo usingRsvp:RSVP_NOT_INVITED];
                                                  
                                                  if (![FriendToEventCoreData isFriendToEventPairExist:eid :friend.uid])
                                                      [FriendToEventCoreData addFriendToEventPair:event :friend];
                                              }
                                          }
                                      }
                                  }
                                  
                                  fbUserInfo.pastEvents = [FriendCoreData getAllPastEventsPertainingToUser:friend.uid];
                                  fbUserInfo.ongoingEvents = [FriendCoreData getAllFutureEventsPertainingToUser:friend.uid];
                                  [FriendCoreData markFriend:friend];
                                  [self.delegate notifyFbUserInfoRequestCompletedWithResult:fbUserInfo];
                              }
                          }];
}

@end
