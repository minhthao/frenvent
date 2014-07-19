//
//  BackwardTimeSupport.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/17/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "BackwardTimeSupport.h"
#import "TimeSupport.h"

int64_t NUM_SECOND_IN_MINUTE = 60;
int64_t NUM_MINUTE_IN_HOUR = 60;
int64_t NUM_SECOND_IN_HOUR = 3600;
int64_t NUM_HOUR_IN_DAY = 24;
int64_t NUM_SECOND_IN_DAY = 86400;

@implementation BackwardTimeSupport

+ (NSString *)getTimeGapName:(int64_t)time;{
    int64_t currentTime = [TimeSupport getCurrentTimeInUnix];
    if (currentTime - time < NUM_SECOND_IN_MINUTE * 2) return @"Just now";
    else if (currentTime - time < NUM_SECOND_IN_HOUR) {
        int64_t numMins =  (currentTime - time) / NUM_SECOND_IN_MINUTE;
        return [NSString stringWithFormat:@"%lld minutes ago", numMins];
    } else if (currentTime - time < NUM_SECOND_IN_HOUR * 2) return @"1 hour ago";
    else if (currentTime - time < NUM_SECOND_IN_DAY) {
        int64_t numHours =  (currentTime - time) / NUM_SECOND_IN_HOUR;
        return [NSString stringWithFormat:@"%lld hours ago", numHours];
    } else {
        int64_t yesterday = [TimeSupport getUnixTime:[TimeSupport getDateTimeOfIthDateFromTodayInStandardFormat:-1]];
        if (time >= yesterday) return @"Yesterday";
        else if (currentTime - time < NUM_SECOND_IN_DAY * 10) {
            int64_t numDays =  (currentTime - time) / NUM_SECOND_IN_DAY;
            return [NSString stringWithFormat:@"%lld days ago", numDays];
        } else {
            return [TimeSupport getDisplayDateTime:time];
        }
    }
}

@end
