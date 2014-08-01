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
#import "FriendCoreData.h"
#import "Event.h"
#import "FriendToEventCoreData.h"
#import "TimeSupport.h"

static int16_t const QUERY_LIMIT = 300;
static int64_t const LOWER_TIME_LIMIT = 1262304000;

@implementation FbUserInfoRequest

#pragma mark - query params
/**
 * Prepare the query method parameters for user events
 * @return dictionary
 */
- (NSDictionary *) prepareFbUserEventQueryParams:(NSString *)uid {
    NSString *events = [NSString stringWithFormat:@"SELECT eid FROM event_member WHERE uid = %@ AND "
                            "(rsvp_status = \"attending\" OR rsvp_status = \"unsure\") AND " //rsvp
                            "start_time > %lld ORDER BY start_time DESC LIMIT %d",
                            uid, LOWER_TIME_LIMIT, QUERY_LIMIT];
    
    NSString *eventsInfo = [NSString stringWithFormat:@"SELECT eid, name, pic_big, start_time, end_time, "
                                "location, venue, attending_count, unsure_count, privacy, host FROM event "
                                "WHERE eid IN (SELECT eid FROM #events)"];
    
    NSString *query = [NSString stringWithFormat:@"{'events':'%@', 'eventsInfo':'%@'}",events, eventsInfo];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

/**
 * Prepare about user query method parameters
 * @return dictionary
 */
- (NSDictionary *) prepareAboutFbUserQueryParams:(NSString *)uid {
    NSString *userInfo = [NSString stringWithFormat:@"SELECT name, pic_cover, mutual_friend_count FROM user WHERE uid = %@", uid];
    NSString *userPhoto = [NSString stringWithFormat:@"SELECT src_big, caption_tags FROM photo WHERE owner = %@ ORDER BY created DESC LIMIT 50", uid];
    
    NSString *query = [NSString stringWithFormat:@"{'userInfo':'%@', 'userPhoto':'%@'}", userInfo, userPhoto];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

/**
 * Prepare the query for recommended friends info
 * @param Set of users's id
 * @return dictionary
 */
- (NSDictionary *) prepareSuggestedFriendQueryParams:(NSSet *)uidSet {
    NSMutableString *uidsString = [[NSMutableString alloc] init];
    NSArray *uids = [uidSet allObjects];
    for (int i = 0; i < [uids count]; i++) {
        if (i != ([uids count] - 1)) [uidsString appendFormat:@"uid = %@ OR ", uids[i]];
        else [uidsString appendFormat:@"uid = %@", uids[i]];
    }
    
    NSString *userInfo = [NSString stringWithFormat:@"SELECT uid, name, pic_cover, mutual_friend_count FROM user WHERE %@", uidsString];
    
    NSString *query = [NSString stringWithFormat:@"{'userInfo':'%@'}", userInfo];
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;

}

/**
 * Public query methods. First check if we can make the query.
 * @param uid
 */
- (void) queryFbUserInfo:(NSString *)uid{
    if ([FBSession activeSession].isOpen &&
        [[FBSession activeSession] hasGranted:@"friends_events"] &&
        [[FBSession activeSession] hasGranted:@"friends_photos"])
        [self doQueryFbUserInfo:uid];
    else if ([FBSession activeSession].state== FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) [self.delegate notifyFbUserInfoRequestFail];
            else if (FB_ISSESSIONOPENWITHSTATE(status)) [self doQueryFbUserInfo:uid];
            else [self.delegate notifyFbUserInfoRequestFail];
        }];
    } else [self.delegate notifyFbUserInfoRequestFail];
}

/**
 * Do the actual query for Fb user info
 * @param uid
 */
- (void) doQueryFbUserInfo:(NSString *)uid {
    //we first get the basic user info and mutual friends
    NSDictionary *aboutUser = [self prepareAboutFbUserQueryParams:uid];
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:aboutUser
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) [self.delegate notifyFbUserInfoRequestFail];
        else [self processFbAboutUserResult:result];
    }];
    
    //we then check whether it is necessary to query for events
    Friend *friend = [FriendCoreData getFriendWithUid:uid];
    if (friend != nil && friend.mark != [NSNumber numberWithBool:true]) {
        NSDictionary *userEvent = [self prepareFbUserEventQueryParams:uid];
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:userEvent
                                     HTTPMethod:@"GET"
              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) [self.delegate notifyFbUserInfoRequestFail];
            else [self processEventsResult:result forFriend:friend];
        }];
    } else if (friend != nil) {
        NSArray *pastEvents = [FriendCoreData getAllPastEventsPertainingToUser:friend.uid];
        NSArray *ongoingEvents = [FriendCoreData getAllFutureEventsPertainingToUser:friend.uid];
        [self.delegate fbUserInfoRequestOngoingEvents:ongoingEvents];
        [self.delegate fbUserInfoRequestPastEvents:pastEvents];
    } else  {
        //if not friend, then we would like to do a separate query to get relevant results
    }
}

/**
 * Do the query for suggested friend info
 * @param NSSet of uids
 */
- (void) doQueryForSuggestedFriends:(NSSet *)uidSet {
    NSDictionary *params = [self prepareSuggestedFriendQueryParams:uidSet];
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
              if (error) [self.delegate notifyFbUserInfoRequestFail];
              else {
                  NSMutableArray *suggestedFriends = [[NSMutableArray alloc] init];
                  NSNull *nullInstance = [NSNull null];
                  NSArray *data = (NSArray *)result[@"data"];
                  NSArray *resultSet = data[0][@"fql_result_set"];
                  for (NSDictionary *infoObj in resultSet) {
                      SuggestFriend *suggestFriend = [[SuggestFriend alloc] init];
                      suggestFriend.uid = infoObj[@"uid"];
                      suggestFriend.name = infoObj[@"name"];
                      suggestFriend.numMutualFriends = [infoObj[@"mutual_friend_count"] intValue];
                      
                      NSString *cover = @"";
                      if ([infoObj[@"pic_cover"] isKindOfClass:[NSDictionary class]]) {
                          NSDictionary *coverDic = infoObj[@"pic_cover"];
                          if (coverDic[@"source"] != nullInstance) {
                              cover = coverDic[@"source"];
                          }
                      }
                      suggestFriend.cover = cover;
                      
                      [suggestedFriends addObject:suggestFriend];
                  }
                  
                  [self.delegate fbUserInfoRequestSuggestedFriends:suggestedFriends];
              }
          }];

}

/**
 * Process about user info data
 * @param result
 */
- (void) processFbAboutUserResult:(id)result {
    NSNull *nullInstance = [NSNull null];
    NSArray *data = (NSArray *)result[@"data"];
    
    for (int i = 0; i < [data count]; i++) {
        NSArray *resultSet = data[i][@"fql_result_set"];
        if ([data[i][@"name"] isEqualToString:@"userInfo"]) {
            if ([resultSet count] == 0) {
                [self.delegate notifyFbUserInfoRequestFail];
                return;
            } else {
                NSDictionary *infoObj = resultSet[0];
                [self.delegate fbUserInfoRequestName:infoObj[@"name"]];
                [self.delegate fbUserInfoRequestMutualFriendsCount:[infoObj[@"mutual_friend_count"] intValue]];
                
                NSString *cover = @"";
                if ([infoObj[@"pic_cover"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *coverDic = infoObj[@"pic_cover"];
                    if (coverDic[@"source"] != nullInstance) {
                        cover = coverDic[@"source"];
                    }
                }
                [self.delegate fbUserInfoRequestProfileCover:cover];
            }
        } else if ([data[i][@"name"] isEqualToString:@"userPhoto"]) {
            NSMutableArray *urls = [[NSMutableArray alloc] init];
            NSMutableSet *suggestedUserUids = [[NSMutableSet alloc] init];
            for (NSDictionary *photoDictionary in resultSet) {
                if ([photoDictionary[@"src_big"] isKindOfClass:[NSString class]])
                    [urls addObject:photoDictionary[@"src_big"]];
                if ([photoDictionary[@"caption_tags"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *tags = (NSDictionary *)photoDictionary[@"caption_tags"];
                    NSArray *tagsArray = [tags allValues];
                    for (NSArray *tagsLocationInText in tagsArray) {
                        for (NSDictionary *tagsDictionary in tagsLocationInText) {
                            if ([tagsDictionary[@"type"] isEqualToString:@"user"]) {
                                NSString *uid = tagsDictionary[@"id"];
                                if ([FriendCoreData getFriendWithUid:uid] == nil)
                                    [suggestedUserUids addObject:uid];
                            }
                        }
                    }
                }
            }
            
            [self.delegate fbUserInfoRequestPhotos:urls];
            
            if ([suggestedUserUids count] == 0) [self.delegate fbUserInfoRequestSuggestedFriends:nil];
            else {
                [self doQueryForSuggestedFriends:suggestedUserUids];
            }
        }
    }
}

/**
 * Process user events info
 * @param uid
 */
- (void)processEventsResult:(id)result forFriend:(Friend *)friend{
    NSArray *data = (NSArray *)result[@"data"];
    NSArray *resultSet = data[1][@"fql_result_set"];
    if ([resultSet count] > 0) {
        for (NSDictionary *eventInfo in resultSet) {
            NSString *eid;
            if ([eventInfo[@"eid"] isKindOfClass:[NSString class]])
                eid = eventInfo[@"eid"];
            else eid = [eventInfo[@"eid"] stringValue];
            Event *event = [EventCoreData getEventWithEid:eid];
            if (event == nil)
                event = [EventCoreData addEvent:eventInfo usingRsvp:RSVP_NOT_INVITED];
            
            if (![FriendToEventCoreData isFriendToEventPairExist:eid :friend.uid])
                [FriendToEventCoreData addFriendToEventPair:event :friend];
        }
        NSArray *pastEvents = [FriendCoreData getAllPastEventsPertainingToUser:friend.uid];
        NSArray *ongoingEvents = [FriendCoreData getAllFutureEventsPertainingToUser:friend.uid];
        [FriendCoreData markFriend:friend];
        
        [self.delegate fbUserInfoRequestOngoingEvents:ongoingEvents];
        [self.delegate fbUserInfoRequestPastEvents:pastEvents];
    }
}


@end
