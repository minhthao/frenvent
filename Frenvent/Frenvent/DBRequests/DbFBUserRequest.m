//
//  DbFBUserRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 8/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "DbFBUserRequest.h"
#import "DBConstants.h"

@implementation DbFBUserRequest

/**
 * Prepare the request to add new fb user
 * @param uid
 * @param name
 * @return NS mutable URL request
 */
+ (NSMutableURLRequest *) prepareAddFbUserRequest:(NSString *)uid :(NSString *)name {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:uid forKey:FBUSER_UID];
    [params setObject:name forKey:FBUSER_NAME];
    [params setObject:@"" forKey:FBUSER_INFO];
    
    NSString *post = [NSString stringWithFormat:@"&%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_POST,
                      REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_FBUSER, REQUEST_DATA, params];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

+(BOOL)addFbUserWithUid:(NSString *)uid andName:(NSString *)name {
    NSMutableURLRequest *request = [self prepareAddFbUserRequest:uid :name];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    return (conn != nil);
}

@end
