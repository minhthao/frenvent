//
//  DbUserRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "DbUserRequest.h"
#import "DBConstants.h"

@implementation DbUserRequest

#pragma mark - private methods
/**
 * Prepare the request to register new user
 * @param uid
 * @param name
 * @param num friend events
 * @param num user events
 * @return NS mutable URL request
 */
- (NSMutableURLRequest *) prepareRegisterUserRequest:(NSString *)uid :(NSString *)name :(NSInteger)numFriendEvents :(NSInteger)numUserEvents {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:uid forKey:USER_UID];
    [params setObject:name forKey:USER_USERNAME];
    [params setObject:[NSNumber numberWithInteger:numFriendEvents] forKey:USER_NUM_FRIENDS_EVENTS];
    [params setObject:[NSNumber numberWithInteger:numUserEvents] forKey:USER_NUM_USER_EVENTS];
    
    NSString *post = [NSString stringWithFormat:@"&%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_POST,
                      REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_USER, REQUEST_DATA, params];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

/**
 * Prepare the update request for number of friend events the user has
 * @param uid
 * @param num friend events
 * @return NS mutable URL request
 */
- (NSMutableURLRequest *) prepareNumFriendEventsRequestUpdate:(NSString *)uid :(NSInteger)numFriendEvents {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:uid forKey:USER_UID];
    [params setObject:[NSNumber numberWithInteger:numFriendEvents] forKey:USER_NUM_FRIENDS_EVENTS];
    
    NSString *post = [NSString stringWithFormat:@"&%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_UPDATE,
                      REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_USER, REQUEST_DATA, params];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

/**
 * Prepare the update request for number of my events the user has
 * @param uid
 * @param num friend events
 * @return NS mutable URL request
 */
- (NSMutableURLRequest *) prepareNumMyEventsRequestUpdate:(NSString *)uid :(NSInteger)numMyEvents {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:uid forKey:USER_UID];
    [params setObject:[NSNumber numberWithInteger:numMyEvents] forKey:USER_NUM_USER_EVENTS];
    
    NSString *post = [NSString stringWithFormat:@"&%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_UPDATE,
                      REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_USER, REQUEST_DATA, params];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

#pragma mark - public methods
/**
 * Register the user with our database
 * @param uid
 * @param name
 * @param num friend events
 * @param num my events
 */
- (void) registerUser:(NSString *)uid :(NSString *)name :(NSInteger)numFriendEvents :(NSInteger)numUserEvents {
    NSMutableURLRequest *request = [self prepareRegisterUserRequest:uid :name :numFriendEvents :numUserEvents];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn) [self.delegate notifyLoginUserRegistered];
    else NSLog(@"Connection could not be made");
}

/**
 * Update the number of friend events
 * @param uid
 * @param num friend events
 */
- (void) updateUserNumFriendEvents:(NSString *)uid :(NSInteger)numFriendEvents {
    NSMutableURLRequest *request = [self prepareNumFriendEventsRequestUpdate:uid :numFriendEvents];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (!conn) NSLog(@"Connection could not be made");
}

/**
 * Update the number of friend events
 * @param uid
 * @param num friend events
 */
- (void) updateUserNumMyEvents:(NSString *)uid :(NSInteger)numMyEvents {
    NSMutableURLRequest *request = [self prepareNumMyEventsRequestUpdate:uid :numMyEvents];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (!conn) NSLog(@"Connection could not be made");
}

@end
