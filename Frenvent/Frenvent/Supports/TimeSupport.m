//
//  TimeSupport.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/23/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "TimeSupport.h"

static NSInteger const NUM_DAY_IN_WEEK = 7;
static NSInteger const NUM_WEEKDAY_IN_WEEK = 5;
static NSInteger const NUM_SECOND_IN_DAY = 60 * 60 * 24;
static NSString * const STANDARD_DATETIME_FORMAT = @"yyyy-MM-dd HH:mm:ss";

@interface TimeSupport()

+ (NSDateFormatter *) getStandardDateFormat;
+ (BOOL) isDateTimeSpecifiedTheHour: (NSString *)dateTimeInStandardFormat;
+ (NSString *) getDisplayHour: (int64_t)dateTimeInUnix;
+ (BOOL) isOfTheSameDay: (NSString *)dateTimeInStandardFormat1
                       : (NSString *)dateTimeInStandardFormat2;
+ (BOOL) isOfTheSameYear: (NSString *)dateTimeInStandardFormat1
                        : (NSString *)dateTimeInStandardFormat2;
+ (NSString *) getTodayDateName;
+ (NSInteger) getTodayDateIndexInWeek;

@end

@implementation TimeSupport

#pragma mark - private methods

/**
 * Get the standard format for the date time
 */
+ (NSDateFormatter *) getStandardDateFormat {
    NSDateFormatter *standardFormat = [[NSDateFormatter alloc] init];
    [standardFormat setDateFormat: STANDARD_DATETIME_FORMAT];
    return standardFormat;
}

/**
 * Check if the date time (provided in standard format) specified the hours
 * @param time in standard format
 * @return boolean
 */
+ (BOOL) isDateTimeSpecifiedTheHour:(NSString *)dateTimeInStandardFormat {
    NSString *hourStr = [[dateTimeInStandardFormat substringFromIndex:11] substringToIndex:5];
    return ![hourStr isEqualToString:@"00:00"];
}

/**
 * Get the display hour of a given date time (provided in unix timestamp)
 * @param unix time
 * @return time in format "h:mm a"
 */
+ (NSString *) getDisplayHour:(int64_t)dateTimeInUnix {
    NSDateFormatter *targetFormat = [[NSDateFormatter alloc] init];
    [targetFormat setDateFormat:@"h:mm a"];
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:(NSTimeInterval)dateTimeInUnix];
    return [targetFormat stringFromDate:date];
}

/**
 * Check whether two DateTimes written in standard format have the same date
 * @param time in standard format 1
 * @param time in standard format 2
 * @return boolean
 */
+ (BOOL) isOfTheSameDay:(NSString *)dateTimeInStandardFormat1
                       :(NSString *)dateTimeInStandardFormat2 {
    NSString *date1Day = [dateTimeInStandardFormat1 substringToIndex:10];
    NSString *date2Day = [dateTimeInStandardFormat2 substringToIndex:10];
    return [date1Day isEqualToString:date2Day];
}

/**
 * Check whether two DatesTimes written in the starndard format have the same year
 * @param time in standard format 1
 * @param time in standard format 2
 * @return boolean
 */
+ (BOOL) isOfTheSameYear:(NSString *)dateTimeInStandardFormat1
                        :(NSString *)dateTimeInStandardFormat2 {
    NSString *date1Day = [dateTimeInStandardFormat1 substringToIndex:4];
    NSString *date2Day = [dateTimeInStandardFormat2 substringToIndex:4];
    return [date1Day isEqualToString:date2Day];
}

/**
 * Get today date name, this is to find the index of the date in week
 * @return today's date name
 */
+ (NSString *) getTodayDateName {
    NSDateFormatter *dateNameFormat = [[NSDateFormatter alloc] init];
    [dateNameFormat setDateFormat:@"EEE"];
    
    NSDate *today = [[NSDate alloc] init];
    return [[dateNameFormat stringFromDate:today] uppercaseString];
}


/**
 * Get index of today in the week starting with Monday
 * @return index of today in the week
 */
+ (NSInteger) getTodayDateIndexInWeek {
    NSString *todayDateName = [self getTodayDateName];
    NSArray *dateNamesInWeek = [[NSArray alloc] initWithObjects:@"MON", @"TUE", @"WED", @"THU", @"FRI", @"SAT", @"SUN", nil];
    for (int i = 0; i < [dateNamesInWeek count]; i++) {
        NSString *dateName = [dateNamesInWeek objectAtIndex:i];
        if ([todayDateName isEqualToString:dateName]) {
            return i;
        }
    }
    return -1;
}


#pragma mark - public time formatting methods
/**
 * Get the standard date/time format of an date/time string
 * @param time in fb format (either "yyyy-MM-dd" or "yyyy-MM-dd'T'HH:mm:ss" or "yyyy-MM-dd'T'HH:mm:ssZ")
 * @return time in standard format
 */
+ (NSString *)getDateTimeInStandardFormat:(NSString *)dateTimeInFacebookFormat {
    NSDateFormatter *standardFormat = [self getStandardDateFormat];
    
    NSDateFormatter *sourceFormat = [[NSDateFormatter alloc] init];
    if (dateTimeInFacebookFormat.length < 12) {
        [sourceFormat setDateFormat:@"yyyy-MM-dd"];
    } else if (dateTimeInFacebookFormat.length < 20) {
        [sourceFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    } else {
        [sourceFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    }
    
    NSDate *date = [sourceFormat dateFromString:dateTimeInFacebookFormat];
    
    return [standardFormat stringFromDate:date];
}

/**
 * Get the unix time of a standard time
 * @param time in standard format
 * @return unix time
 */
+ (int64_t) getUnixTime:(NSString *)dateTimeInStandardFormat {
    NSDateFormatter *standardFormat = [self getStandardDateFormat];
    NSDate *date = [standardFormat dateFromString:dateTimeInStandardFormat];
    return (NSInteger) [date timeIntervalSince1970];
}

/**
 * Get the current time in unix
 * @return unix time
 */
+ (int64_t) getCurrentTimeInUnix {
    NSDate *date = [[NSDate alloc] init];
    return (NSInteger) [date timeIntervalSince1970];
}

/**
 * Get the DateTime in standard format from the unix time
 * @param unix time
 * @return time in standard format
 */
+ (NSString *) getDateTimeFromUnixTimeInStandardFormat:(int64_t)dateTimeInUnix {
    NSDateFormatter *standardFormat = [self getStandardDateFormat];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:(NSTimeInterval) dateTimeInUnix];
    return [standardFormat stringFromDate:date];
}

/**
 * Get the DateTime of today in standard  format
 * @return time in standard format
 */
+ (NSString *) getDateTimeOfTodayInStandardFormat {
    NSDateFormatter *targetFormat = [[NSDateFormatter alloc] init];
    [targetFormat setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *date = [[NSDate alloc] init];
    return [targetFormat stringFromDate:date];
}

/**
 * Get the DateTime of ith Date away from today in standard format
 * @param ith index
 * @return time in standard time
 */
+ (NSString *) getDateTimeOfIthDateFromTodayInStandardFormat: (NSInteger) ithValue {
    NSDateFormatter *targetFormat = [[NSDateFormatter alloc] init];
    [targetFormat setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:(NSTimeInterval) (NUM_SECOND_IN_DAY * ithValue)];
    return [targetFormat stringFromDate:date];
}

/**
 * Get the display date from unix time, the display is typically be on the list view
 * @param unix time
 * @return time in display format
 */
+ (NSString *) getDisplayDateTime:(int64_t)dateTimeInUnix {
    NSString *dateTimeInStandardFormat = [self getDateTimeFromUnixTimeInStandardFormat:dateTimeInUnix];
    NSString *todayInStandardFormat = [self getDateTimeOfTodayInStandardFormat];
    NSString *tomorrowInStandardFormat = [self getDateTimeOfIthDateFromTodayInStandardFormat:1];
    
    NSDateFormatter *targetFormat = [[NSDateFormatter alloc] init];
    if ([self isDateTimeSpecifiedTheHour:dateTimeInStandardFormat]) {
        if ([self isOfTheSameDay:dateTimeInStandardFormat :todayInStandardFormat]) {
            [targetFormat setDateFormat:@"'Today at' h:mm a"];
        } else if ([self isOfTheSameDay:dateTimeInStandardFormat :tomorrowInStandardFormat]) {
            [targetFormat setDateFormat:@"'Tomorrow at' h:mm a"];
        } else if ([self isOfTheSameYear:dateTimeInStandardFormat :todayInStandardFormat]) {
            [targetFormat setDateFormat:@"EEE, MMM d 'at' h:mm a"];
        } else {
            [targetFormat setDateFormat:@"EEE, MMM d, yyyy 'at' h:mm a"];
        }
    } else { //the date did not specified the hours
        if ([self isOfTheSameDay:dateTimeInStandardFormat :todayInStandardFormat]) {
            return @"Today";
        } else if ([self isOfTheSameDay:dateTimeInStandardFormat :tomorrowInStandardFormat]) {
            return @"Tomorrow";
        } else if ([self isOfTheSameYear:dateTimeInStandardFormat :todayInStandardFormat]) {
            [targetFormat setDateFormat:@"EEE, MMM d"];
        } else {
            [targetFormat setDateFormat:@"EEE, MMM d, yyyy"];
        }
    }
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:(NSTimeInterval)dateTimeInUnix];
    return [targetFormat stringFromDate:date];
    
}

/**
 * Get the display date from the unix time, the display time if typically tie to the detail view
 * @param unix time 1 (start time)
 * @param unix time 2 (end time)
 * @return time frame in display format
 */
+ (NSString *) getFullDisplayDateTime:(int64_t)startTimeInUnix
                                     :(int64_t)endTimeInUnix {
    if (endTimeInUnix == 0) {
        return [self getDisplayDateTime:startTimeInUnix];
    } else {
        NSString *displayDateTime = [self getDisplayDateTime:startTimeInUnix];
        
        //check if the event is within the same date
        NSString *dateTimeInStandardFormat1 = [self getDateTimeFromUnixTimeInStandardFormat:startTimeInUnix];
        NSString *dateTimeInStandardFormat2 = [self getDateTimeFromUnixTimeInStandardFormat:endTimeInUnix];
        if ([self isOfTheSameDay:dateTimeInStandardFormat1 :dateTimeInStandardFormat2]) {
            return [[displayDateTime stringByAppendingString:@" - "]
                    stringByAppendingString:[self getDisplayHour:endTimeInUnix]];
        } else {
            return [[displayDateTime stringByAppendingString:@" - "]
                    stringByAppendingString:[self getDisplayDateTime:endTimeInUnix]];
        }
    }
}

#pragma mark - public time frame methods
/**
 * Get the start time in today's timeframe
 * @return time in unix
 */
+ (int64_t) getTodayTimeFrameStartTimeInUnix {
    return [self getUnixTime:[self getDateTimeOfTodayInStandardFormat]];
}

/**
 * Get the end time in today's timeframe
 * @return time in unix
 */
+ (int64_t) getTodayTimeFrameEndTimeInUnix {
    return [self getTodayTimeFrameStartTimeInUnix] + NUM_SECOND_IN_DAY;
}

/**
 * Get the start time in this weekend's timeframe
 * @return time in unix
 */
+ (int64_t) getThisWeekendTimeFrameStartTimeInUnix {
    NSInteger todayDateIndexInWeek = [self getTodayDateIndexInWeek];
    
    NSInteger startingDateIndexFromToday = NUM_WEEKDAY_IN_WEEK - todayDateIndexInWeek;
    if (startingDateIndexFromToday < 0) {
        startingDateIndexFromToday = 0;
    }
    
    return [self getUnixTime:[self getDateTimeOfIthDateFromTodayInStandardFormat:startingDateIndexFromToday]];
}

/**
 * Get the end time in this weekend's timeframe
 * @return time in unix
 */
+ (int64_t) getThisWeekendTimeFrameEndTimeInUnix {
    NSInteger todayDateIndexInWeek = [self getTodayDateIndexInWeek];
    NSInteger endDateIndexFromToday = NUM_DAY_IN_WEEK - todayDateIndexInWeek;
    return [self getUnixTime:[self getDateTimeOfIthDateFromTodayInStandardFormat:endDateIndexFromToday]];
}

/**
 * Get the start time in this week's timeframe
 * @return time in unix
 */
+ (int64_t) getThisWeekTimeFrameStartTimeInUnix {
    return [self getThisWeekTimeFrameEndTimeInUnix] - (NUM_SECOND_IN_DAY * NUM_DAY_IN_WEEK);
}

/**
 * Get the end time in this week's timeframe
 * @return time in unix
 */
+ (int64_t) getThisWeekTimeFrameEndTimeInUnix {
    return [self getThisWeekendTimeFrameEndTimeInUnix];
}

/**
 * Get the start time in next week's timeframe 
 * @return time in unix
 */
+ (int64_t) getNextWeekTimeFrameStartTimeInUnix {
    return [self getThisWeekTimeFrameEndTimeInUnix];
}

/**
 * Get the end time in next week's timeframe
 * @return time in unix
 */
+ (int64_t) getNextWeekTimeFrameEndTimeInUnix {
    return [self getNextWeekTimeFrameStartTimeInUnix] + NUM_DAY_IN_WEEK * NUM_SECOND_IN_DAY;
}

@end
