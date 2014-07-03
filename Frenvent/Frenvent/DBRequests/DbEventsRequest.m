//
//  DbEventsRequests.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "DbEventsRequest.h"
#import "DBConstants.h"
#import "TimeSupport.h"
#import "AFNetworking.h"

static double const DISTANCE_RADIUS = 30;

@interface DbEventsRequest()

- (NSMutableURLRequest *) prepareNearbyEventsQueryRequest:(double)currentLocLongitude :(double)currentLocLatitude;
- (NSMutableURLRequest *) prepareNearbyEventsQueryRequest:(double)lowerLong :(double)lowerLat :(double)upperLong :(double)upperLat;

@end

@implementation DbEventsRequest
#pragma mark - private methods
/**
 * Prepare the nearby events query request with centered at your current location and predefined radius
 * @param current longitude
 * @param current latitude
 * @return NS mutable URL request
 */
- (NSMutableURLRequest *) prepareNearbyEventsQueryRequest:(double)currentLocLongitude :(double)currentLocLatitude {
    int64_t startDay = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    int64_t endDay = [TimeSupport getNextWeekTimeFrameEndTimeInUnix];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"" forKey:EVENT_NAME];
    [params setObject:[NSNumber numberWithDouble:DISTANCE_RADIUS] forKey:EVENT_DISTANCE];
    [params setObject:[NSNumber numberWithDouble:currentLocLongitude] forKey:EVENT_LONGITUDE];
    [params setObject:[NSNumber numberWithDouble:currentLocLatitude] forKey:EVENT_LATITUDE];
    [params setObject:[NSNumber numberWithLongLong:startDay] forKey:EVENT_START_TIME];
    [params setObject:[NSNumber numberWithLongLong:endDay] forKey:EVENT_END_TIME];
    
    NSData* nsdata = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSMutableString* jsonString =[[NSMutableString alloc] initWithData:nsdata encoding:NSASCIIStringEncoding];
    
    CFStringRef originalString = (__bridge CFStringRef)jsonString;
    
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,originalString, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
    
    
    NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_GET,REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_EVENT, REQUEST_DATA, encodedString];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
   
    return request;
}

- (NSMutableURLRequest *) prepareNearbyEventsQueryRequest:(double)lowerLong :(double)lowerLat :(double)upperLong :(double)upperLat {
    
    int64_t startDay = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    int64_t endDay = [TimeSupport getNextWeekTimeFrameEndTimeInUnix];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithDouble:lowerLong] forKey:PUBLIC_EVENT_LOWER_LONGITUDE];
    [params setObject:[NSNumber numberWithDouble:lowerLat] forKey:PUBLIC_EVENT_LOWER_LATITUDE];
    [params setObject:[NSNumber numberWithDouble:upperLong] forKey:PUBLIC_EVENT_UPPER_LONGITUDE];
    [params setObject:[NSNumber numberWithDouble:upperLat] forKey:PUBLIC_EVENT_UPPER_LATITUDE];
    [params setObject:[NSNumber numberWithLongLong:startDay] forKey:PUBLIC_EVENT_TIME_FRAME_BEGIN];
    [params setObject:[NSNumber numberWithLongLong:endDay] forKey:PUBLIC_EVENT_TIME_FRAME_END];
    
    NSData* nsdata = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSMutableString* jsonString =[[NSMutableString alloc] initWithData:nsdata encoding:NSASCIIStringEncoding];
    
    CFStringRef originalString = (__bridge CFStringRef)jsonString;
    
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,originalString, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
    
    
    NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_GET,REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_EVENT, REQUEST_DATA, encodedString];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

#pragma mark - public methods
- (void) uploadEvents:(NSArray *)events {
    
}

- (void) getNearbyEvents:(double)currentLocLongitude :(double)currentLocLatitude {
    NSMutableURLRequest *request = [self prepareNearbyEventsQueryRequest:currentLocLongitude :currentLocLatitude];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer new];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:responseObject];
        NSArray *queriedEvents = [dict objectForKey:RESPONSE_DATA];
        NSUInteger n = [queriedEvents count];
        for (int i = 0; i < n; i++) {
            NSLog(@"Event %i (type: %@): \n%@", (i+1), [queriedEvents[i] class], queriedEvents[i]);
        }
        //[self cacheQueriedData:queriedEvents]; // Do this in background thread
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error getting public events: %@", [error localizedDescription]);
    }];
    
    [operation start];
}

- (void) getNearbyEvents:(double)lowerLong :(double)lowerLat :(double)upperLong :(double)upperLat {
    
}

@end
