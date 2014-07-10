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
#import "Event.h"
#import "EventCoreData.h"

static double const DISTANCE_RADIUS = 30;

@interface DbEventsRequest()
- (NSMutableURLRequest *) prepareEventsUploadRequest:(NSArray *)events;
- (NSMutableURLRequest *) prepareNearbyEventsQueryRequest:(double)currentLocLongitude :(double)currentLocLatitude;
- (NSMutableURLRequest *) prepareNearbyEventsQueryRequest:(double)lowerLong :(double)lowerLat :(double)upperLong :(double)upperLat;
- (void) processEvents:(NSArray *)queriedEvents;

@end

@implementation DbEventsRequest
#pragma mark - private methods
/**
 * Prepare the events upload request
 * @param Array of Event
 * @return NS mutual URL request
 */
- (NSMutableURLRequest *) prepareEventsUploadRequest:(NSArray *)events {
    NSMutableArray* jsonArray = [[NSMutableArray alloc] init];
    
    for (Event *event in events) {
        NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
        [eventDict setObject:event.eid forKey:EVENT_EID];
        [eventDict setObject:event.name forKey:EVENT_NAME];
        [eventDict setObject:event.picture forKey:EVENT_PICTURE];
        [eventDict setObject:event.startTime forKey:EVENT_START_TIME];
        [eventDict setObject:event.endTime forKey:EVENT_END_TIME];
        [eventDict setObject:event.location forKey:EVENT_LOCATION];
        [eventDict setObject:event.longitude forKey:EVENT_LONGITUDE];
        [eventDict setObject:event.latitude forKey:EVENT_LATITUDE];
        [eventDict setObject:event.privacy forKey:EVENT_PRIVACY];
        [eventDict setObject:event.host forKey:EVENT_HOST];
        [eventDict setObject:event.numInterested forKey:EVENT_NUM_INTERESTS];
        [jsonArray addObject:eventDict];
    }
    
    NSData* nsdata = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:nil];
    NSMutableString* jsonString =[[NSMutableString alloc] initWithData:nsdata encoding:NSASCIIStringEncoding];
    
    CFStringRef originalString = (__bridge CFStringRef)jsonString;
    
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalString, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
    
    
    NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_POST,
                      REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_EVENT, REQUEST_DATA, encodedString];
    
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
 * Prepare the nearby events query request with a bounded longitudes and latitudes
 * @param lower longitude
 * @param lower latitude
 * @param upper longitude
 * @param upper latitude
 * @return NS mutable URL request
 */
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
 * Process the queried events
 * @param queried events
 */
- (void) processEvents:(NSArray *)queriedEvents {
    for (NSDictionary *eventObj in queriedEvents) {
        NSString *eid = eventObj[EVENT_EID];
        NSString *name = eventObj[EVENT_NAME];
        NSString *picture = eventObj[EVENT_PICTURE];
        int64_t startTime = [eventObj[EVENT_START_TIME] longLongValue];
        int64_t endTime = [eventObj[EVENT_END_TIME] longLongValue];
        NSString *location = eventObj[EVENT_LOCATION];
        double longitude = [eventObj[EVENT_LONGITUDE] doubleValue];
        double latitude = [eventObj[EVENT_LATITUDE] doubleValue];
        NSString *privacy = eventObj[EVENT_PRIVACY];
        NSString *host = eventObj[EVENT_HOST];
        int32_t numInterested = [eventObj[EVENT_NUM_INTERESTS] intValue];
        NSString *rsvp = RSVP_NOT_INVITED;

        if ([EventCoreData getEventWithEid:eid] == nil)
            [EventCoreData addEventUsingEid:eid name:name picture:picture startTime:startTime endTime:endTime location:location longitude:longitude latitude:latitude host:host privacy:privacy numInterested:numInterested rsvp:rsvp];
    }
}

#pragma mark - public methods
/**
 * Upload the events to our host Db
 * @param Array of Event
 */
- (void) uploadEvents:(NSArray *)events {
    NSMutableURLRequest *request = [self prepareEventsUploadRequest:events];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(connection) [self.delegate notifyEventsUploaded];
    else NSLog(@"Error -Connection could not be made");
}

/**
 * Init the nearby events.
 * @param current longitude
 * @param current latitude
 */
- (void) initNearbyEvents:(double)currentLocLongitude :(double)currentLocLatitude {
    NSMutableURLRequest *request = [self prepareNearbyEventsQueryRequest:currentLocLongitude :currentLocLatitude];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer new];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:responseObject];
        NSArray *queriedEvents = [dict objectForKey:RESPONSE_DATA];
        [self processEvents:queriedEvents];
        [self.delegate notifyNearbyEventsInitialized];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error getting public events: %@", [error localizedDescription]);
    }];
    
    [operation start];
}

/**
 * Refresh the nearby events
 * @param lower longitude
 * @param lower latitude
 * @param upper longitude
 * @param upper latitude
 */
- (void) refreshNearbyEvents:(double)lowerLong :(double)lowerLat :(double)upperLong :(double)upperLat {
    NSMutableURLRequest *request = [self prepareNearbyEventsQueryRequest:lowerLong :lowerLat :upperLong :upperLat];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer new];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:responseObject];
        NSArray *queriedEvents = [dict objectForKey:RESPONSE_DATA];
        [self processEvents:queriedEvents];
        [self.delegate notifyNearbyEventsRefreshedWithResults:[EventCoreData getNearbyEventsBoundedByLowerLongitude:lowerLong lowerLatitude:lowerLat upperLongitude:upperLong upperLatitude:upperLat]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error getting public events: %@", [error localizedDescription]);
    }];
    [operation start];
}

@end
