//
//  DBNotificationRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 8/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "DBNotificationRequest.h"
#import "DBConstants.h"
#import "Constants.h"
#import "TimeSupport.h"
#import "AFNetworking.h"
#import "NotificationCoreData.h"
#import "EventCoreData.h"
#import "FriendCoreData.h"

@implementation DBNotificationRequest
/**
 * Prepare the request to add new notification
 * @param uid
 * @param name
 * @param start time
 * @return NS mutable URL request
 */
+ (NSMutableURLRequest *) prepareAddNotificationRequestForFriend:(NSString *)friendUid andEvent:(NSString *)eid andStartTime:(int64_t)startTime {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [defaults stringForKey:FB_LOGIN_USER_ID];
    int64_t timeStamp = [TimeSupport getCurrentTimeInUnix];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:uid forKey:IOS_NOTIFICATION_UID];
    [params setObject:friendUid forKey:IOS_NOTIFICATION_FRIEND_UID];
    [params setObject:eid forKey:IOS_NOTIFICATION_EID];
    [params setObject:[NSNumber numberWithLongLong:startTime] forKey:IOS_NOTIFICATION_START_TIME];
    [params setObject:[NSNumber numberWithLongLong:timeStamp] forKey:IOS_NOTIFICATION_TIMESTAMP];
    
    NSString *post = [NSString stringWithFormat:@"&%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_POST,
                      REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_IOS_NOTIFICATION, REQUEST_DATA, params];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

/**
 * Add the notification for given friend/event pair
 * @param friend uid
 * @param eid
 * @param start time
 */
+(BOOL)addNotificationForFriend:(NSString *)uid andEvent:(NSString *)eid andStartTime:(int64_t)startTime {
    NSMutableURLRequest *request = [self prepareAddNotificationRequestForFriend:uid andEvent:eid andStartTime:startTime];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    return (connection != nil);
}


/**
 * Prepare the notification request
 * @return NS mutable URL request
 */
- (NSMutableURLRequest *) prepareGetNotificationRequest {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [defaults stringForKey:FB_LOGIN_USER_ID];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:uid forKey:IOS_NOTIFICATION_UID];
    [params setObject:[NSNumber numberWithLongLong:[TimeSupport getCurrentTimeInUnix]] forKey:IOS_NOTIFICATION_START_TIME];
    
    NSData* nsdata = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSMutableString* jsonString =[[NSMutableString alloc] initWithData:nsdata encoding:NSUTF8StringEncoding];
    
    CFStringRef originalString = (__bridge CFStringRef)jsonString;
    
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,originalString, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
    
    
    NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_GET,REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_IOS_NOTIFICATION, REQUEST_DATA, encodedString];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}



/**
 * get the notification associate with this user
 */
- (void)getNotifications {
    NSMutableURLRequest *request = [self prepareGetNotificationRequest];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer new];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:responseObject];
        NSArray *queriedNotifications = [dict objectForKey:RESPONSE_DATA];
        [self processNotifications:queriedNotifications];
        [self.delegate notifyNotificationComplete];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error getting past notifications: %@", [error localizedDescription]);
        [self.delegate notifyNotificationComplete];
    }];
    
    [operation start];
}


/**
 * Process the queried events
 * @param queried events
 */
- (void) processNotifications:(NSArray *)queriedNotifications {
    for (NSDictionary *notificationObj in queriedNotifications) {
        NSString *uid = notificationObj[IOS_NOTIFICATION_FRIEND_UID];
        NSString *eid = notificationObj[IOS_NOTIFICATION_EID];
        NSNumber *time = notificationObj[IOS_NOTIFICATION_TIMESTAMP];
        
        Event *event = [EventCoreData getEventWithEid:eid];
        Friend *friend = [FriendCoreData getFriendWithUid:uid];
        if (event != nil && friend != nil) {
            [NotificationCoreData addNotificationForEvent:event andFriend:friend andTime:time];
        }
    }
}



@end
