//
//  FriendRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendsRequest.h"
#import "FriendCoreData.h"
#import "Friend.h"
#import "TimeSupport.h"

static int16_t const QUERY_LIMIT = 5000;

@interface FriendsRequest()

- (NSDictionary *) prepareFriendsQueryParams;

@end

@implementation FriendsRequest

#pragma mark - private methods
/**
 * prepare the query for all of my friends method's parameters
 * @return dictionary
 */
- (NSDictionary *) prepareFriendsQueryParams {
    NSString *friendInfo = [NSString stringWithFormat:@"SELECT uid, name, pic_cover FROM user WHERE uid IN "
                            "(SELECT uid2 FROM friend WHERE uid1 = me() LIMIT %d) LIMIT %d", QUERY_LIMIT, QUERY_LIMIT];
    NSDictionary *queryParams = @{@"q": friendInfo};
    return queryParams;
}

#pragma mark - public methods
/**
 * Init the friends list at login
 */
- (void) initFriends {
    if ([FBSession activeSession].isOpen) [self doInit];
    else if ([FBSession activeSession].state== FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          // if login fails for any reason, we alert
                                          if (error) {
                                              NSLog(@"error open session");
                                              [self.delegate notifyFriendsQueryError];
                                          } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                              [self doInit];
                                          } else [self.delegate notifyFriendsQueryError];
                                      }
         ];
    } else [self.delegate notifyFriendsQueryError];
}

//the actual work for initialization
- (void) doInit {
    NSDictionary *queryParams = [self prepareFriendsQueryParams];
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParams
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
        if (error) [self.delegate notifyFriendsQueryError];
        else {
            NSArray *data = (NSArray *)result[@"data"];
              
            //get approprivate info arrays
            for (int i = 0; i < [data count]; i++) {
                NSString *uid = [NSString stringWithFormat:@"%@", data[i][@"uid"]];
                NSString *name = data[i][@"name"];
                
                NSString *cover = @"";
                if ([data[i][@"pic_cover"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *coverDic = data[i][@"pic_cover"];
                    if (coverDic[@"source"] != [NSNull null]) {
                        cover = coverDic[@"source"];
                    }
                }
                
                Friend *friend = [FriendCoreData getFriendWithUid:uid];
                if (friend == nil)
                    [FriendCoreData addFriend:uid :name :cover];
                else if ([cover length] > 0 && [friend.cover length] == 0)
                    [FriendCoreData updateFriendCover:friend :cover];

            }
            [self.delegate notifyFriendsQueryCompleted];
        }
    }];
}

@end
