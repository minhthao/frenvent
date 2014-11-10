//
//  EventDetailRecommendUserRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 8/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventDetailRecommendUserRequest.h"
#import "SuggestFriend.h"
#import "Constants.h"

static int const QUERY_LIMIT = 500;

@implementation EventDetailRecommendUserRequest

/**
 * Prepare the query method parameters
 * @return dictionary
 */
- (NSDictionary *) prepareQueryParams:(NSString *)eid {
    NSString *participants = [NSString stringWithFormat:@"SELECT uid, rsvp_status FROM event_member WHERE eid = %@ "
                              "AND (rsvp_status = \"attending\" OR rsvp_status = \"unsure\") "
                              "AND uid != me() AND NOT (uid IN (SELECT uid2 FROM friend WHERE uid1 = me())) LIMIT %d",
                              eid, QUERY_LIMIT];
    NSString *participantInfo = @"SELECT uid, name, mutual_friend_count, sex, pic_cover FROM user "
                                 "WHERE uid IN (SELECT uid FROM #participants)";
                                   
                                   
                                   
    NSString *query = [NSString stringWithFormat:@"{'participants':'%@', 'participantInfo':'%@'}",
                       participants, participantInfo];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

-(void)queryRecommendUser:(NSString *)eid {
    if ([FBSession activeSession].isOpen &&
        [[FBSession activeSession] hasGranted:@"friends_events"] &&
        [[FBSession activeSession] hasGranted:@"user_events"] ) {
        
        [self doQueryForRecommendUser:eid];
    } else if ([FBSession activeSession].state== FBSessionStateCreatedTokenLoaded) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (error) [self.delegate notifyEventDetailRecommendUserQueryFail];
                                          else if (FB_ISSESSIONOPENWITHSTATE(status)) [self doQueryForRecommendUser:eid];
                                          else [self.delegate notifyEventDetailRecommendUserQueryFail];
                                      }];
    } else [self.delegate notifyEventDetailRecommendUserQueryFail];
}

-(void)doQueryForRecommendUser:(NSString *)eid {
    NSDictionary *queryParams = [self prepareQueryParams:eid];
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParams
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error) {
                                  [self.delegate notifyEventDetailRecommendUserQueryFail];
                              } else {
                                  NSNull *nullInstance = [NSNull null];
                                  NSMutableArray *recommendUsers = [[NSMutableArray alloc] init];
                                  NSMutableDictionary *participantsDictionary = [[NSMutableDictionary alloc] init];
                                  
                                  NSArray *data = (NSArray *)result[@"data"];
                                  NSArray *participants = data[0][@"fql_result_set"];
                                  for (NSDictionary *participant in participants)
                                      [participantsDictionary setObject:participant[@"rsvp_status"] forKey:participant[@"uid"]];
                                  
                                  NSArray *participantsInfo = data[1][@"fql_result_set"];
                                  for (NSDictionary *participantInfo in participantsInfo) {
                                      SuggestFriend *suggestFriend = [[SuggestFriend alloc] init];
                                      suggestFriend.uid = [NSString stringWithFormat:@"%@", participantInfo[@"uid"]];
                                      suggestFriend.name = participantInfo[@"name"];
                                      suggestFriend.numMutualFriends = [participantInfo[@"mutual_friend_count"] intValue];
                                      suggestFriend.gender = participantInfo[@"sex"];
                                      suggestFriend.rsvpStatus = participantsDictionary[participantInfo[@"uid"]];
                                      
                                      NSString *cover = @"";
                                      if ([participantInfo[@"pic_cover"] isKindOfClass:[NSDictionary class]]) {
                                          NSDictionary *coverDic = participantInfo[@"pic_cover"];
                                          if (coverDic[@"source"] != nullInstance) {
                                              cover = coverDic[@"source"];
                                          }
                                      }
                                      suggestFriend.cover = cover;
                                      
                                      [recommendUsers addObject:suggestFriend];
                                    }
                                  
                                  //now we sort the suggest friends
                                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                  NSString *userGender = [defaults stringForKey:FB_LOGIN_USER_GENDER];
                                 
                                  [recommendUsers sortUsingComparator:^(SuggestFriend * user1, SuggestFriend *user2){
                                      if ([user1.gender isEqualToString:user2.gender]) {
                                          if (user1.numMutualFriends >  user2.numMutualFriends) return NSOrderedAscending;
                                          else if (user1.numMutualFriends < user2.numMutualFriends) return NSOrderedDescending;
                                          else return NSOrderedSame;
                                      } else if ([user1.gender isEqualToString:userGender] && ![user2.gender isEqualToString:userGender]) {
                                          if (user1.numMutualFriends > 5 && user2.numMutualFriends == 0) return NSOrderedAscending;
                                          else return NSOrderedDescending;
                                      } else {
                                          if (user1.numMutualFriends == 0 && user2.numMutualFriends > 5) return NSOrderedDescending;
                                          else return NSOrderedAscending;
                                      }
                                  }];
                                  
                                  NSMutableArray *suggestFriends = [[NSMutableArray alloc] init];
                                  for (int i = 0; i < MIN(10, [recommendUsers count]); i++) {
                                      if (((SuggestFriend *)[recommendUsers objectAtIndex:i]).numMutualFriends > 5 ||
                                          [suggestFriends count] < 5)
                                          [suggestFriends addObject:[recommendUsers objectAtIndex:i]];
                                  }
                                  
                                  [self.delegate notifyEventDetailRecommendUserCompleteWithResult:suggestFriends];
                              }
                          }];
}


@end
