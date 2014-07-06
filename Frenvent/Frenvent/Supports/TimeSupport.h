//
//  TimeSupport.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/23/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeSupport : NSObject

+ (NSString *) getDateTimeInStandardFormat: (NSString *)dateTimeInFacebookFormat;
+ (int64_t) getUnixTime: (NSString *)dateTimeInStandardFormat;
+ (int64_t) getCurrentTimeInUnix;
+ (NSString *) getDateTimeFromUnixTimeInStandardFormat: (NSInteger)dateTimeInUnix;
+ (NSString *) getDateTimeOfTodayInStandardFormat;
+ (NSString *) getDateTimeOfIthDateFromTodayInStandardFormat: (NSInteger) ithValue;
+ (NSString *) getDisplayDateTime: (NSInteger)dateTimeInUnix;
+ (NSString *) getFullDisplayDateTime: (NSInteger)startTimeInUnix
                                     : (NSInteger)endTimeInUnix;

+ (int64_t) getTodayTimeFrameStartTimeInUnix;
+ (int64_t) getTodayTimeFrameEndTimeInUnix;
+ (int64_t) getThisWeekendTimeFrameStartTimeInUnix;
+ (int64_t) getThisWeekendTimeFrameEndTimeInUnix;
+ (int64_t) getThisWeekTimeFrameStartTimeInUnix;
+ (int64_t) getThisWeekTimeFrameEndTimeInUnix;
+ (int64_t) getNextWeekTimeFrameStartTimeInUnix;
+ (int64_t) getNextWeekTimeFrameEndTimeInUnix;

@end
