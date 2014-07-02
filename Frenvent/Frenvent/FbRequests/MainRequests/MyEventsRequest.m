//
//  MyEventsRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "MyEventsRequest.h"
#import "TimeSupport.h"
#import "EventCoreData.h"
#import "Constants.h"

static NSInteger const QUERY_LIMIT = 400;

@interface MyEventsRequest()
- (NSDictionary *) prepareAllEventsQueryParams;
@end

@implementation MyEventsRequest

#pragma mark - private methods
/**
 * prepare the query for all of my events method parameters
 * @return dictionary
 */
- (NSDictionary *) prepareAllEventsQueryParams {
    int64_t todayTime = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    NSString *myEvents = [NSString stringWithFormat:@"SELECT eid, rsvp_status FROM event_member WHERE uid = me() "
                          "AND ((rsvp_status = \"attending\" OR rsvp_status = \"unsure\") AND start_time < %lld) "
                          "OR , todayTime];
    return nil;
}



@end
