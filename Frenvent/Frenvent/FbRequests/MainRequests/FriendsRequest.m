//
//  FriendRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendsRequest.h"
#import "FriendCoreData.h"

static NSInteger const QUERY_LIMIT = 5000;

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
    NSString *friendInfo = [NSString stringWithFormat:@"SELECT uid, name FROM user WHERE uid IN "
                            "(SELECT uid2 FROM friend WHERE uid1 = me() LIMIT %d) LIMIT %d", QUERY_LIMIT, QUERY_LIMIT];
    NSDictionary *queryParams = @{@"q": friendInfo};
    return queryParams;
}

#pragma mark - public methods
/**
 * Init the friends list at login
 */
- (void) initFriends {
    NSDictionary *queryParams = [self prepareFriendsQueryParams];
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParams
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSArray *data = (NSArray *)result[@"data"];
                                  
                                  //get approprivate info arrays
                                  for (int i = 0; i < [data count]; i++) {
                                      NSString *uid = [data[i][@"uid"] stringValue];
                                      NSString *name = data[i][@"name"];
                                      if ([FriendCoreData getFriendWithUid:uid] == nil)
                                          [FriendCoreData addFriend:uid :name];
                                  }
                              }
                              
                              [self.delegate notifyFriendsQueryCompleted];
                          }];

}


@end
