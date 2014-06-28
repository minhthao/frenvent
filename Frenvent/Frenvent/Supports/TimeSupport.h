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
+ (NSInteger) getUnixTime: (NSString *)dateTimeInStandardFormat;
+ (NSString *) getDateTimeFromUnixTimeInStandardFormat: (NSInteger)dateTimeInUnix;
+ (NSString *) getDateTimeOfTodayInStandardFormat;
+ (NSString *) getDateTimeOfIthDateFromTodayInStandardFormat: (NSInteger) ithValue;
+ (NSString *) getDisplayDateTime: (NSInteger)dateTimeInUnix;
+ (NSString *) getFullDisplayDateTime: (NSInteger)startTimeInUnix
                                     : (NSInteger)endTimeInUnix;

+ (NSInteger) getTodayTimeFrameStartTimeInUnix;
+ (NSInteger) getTodayTimeFrameEndTimeInUnix;
+ (NSInteger) getThisWeekendTimeFrameStartTimeInUnix;
+ (NSInteger) getThisWeekendTimeFrameEndTimeInUnix;
+ (NSInteger) getThisWeekTimeFrameStartTimeInUnix;
+ (NSInteger) getThisWeekTimeFrameEndTimeInUnix;
+ (NSInteger) getNextWeekTimeFrameStartTimeInUnix;
+ (NSInteger) getNextWeekTimeFrameEndTimeInUnix;

@end
