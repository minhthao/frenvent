//
//  EventManager.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/6/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventManager.h"
#import "Event.h"
#import "TimeSupport.h"

static NSString * const TODAY_EVENTS_HEADER = @"TODAY";
static NSString * const THIS_WEEK_EVENTS_HEADER = @"THIS WEEK";
static NSString * const THIS_WEEKEND_EVENTS_HEADER = @"THIS WEEKEND";
static NSString * const NEXT_WEEK_EVENTS_HEADER = @"NEXT WEEK";
static NSString * const OTHER_EVENTS_HEADER = @"OTHER";

@interface EventManager()

- (NSMutableArray *)getSectionTitlesArray;

@end

@implementation EventManager

#pragma mark - private method
/**
 * Get the title array for sections
 * @return Array of Title string
 */
- (NSMutableArray *)getSectionTitlesArray {
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    if ([_todayEvents count] > 0) [sectionTitles addObject:TODAY_EVENTS_HEADER];
    if ([_thisWeekEvents count] > 0) [sectionTitles addObject:THIS_WEEKEND_EVENTS_HEADER];
    if ([_thisWeekendEvents count] > 0) [sectionTitles addObject:THIS_WEEKEND_EVENTS_HEADER];
    if ([_nextWeekEvents count] > 0) [sectionTitles addObject:NEXT_WEEK_EVENTS_HEADER];
    if ([_otherEvents count] > 0) [sectionTitles addObject:OTHER_EVENTS_HEADER];
    
    return sectionTitles;
}

#pragma mark - public methods
/**
 * Set the events
 * This will classified the events into 5 separate category by time
 * @param Array of Event
 */
- (void)setEvents:(NSArray *)eventsArray {
    if (_todayEvents == nil) _todayEvents = [[NSMutableArray alloc] init];
    else [_todayEvents removeAllObjects];
    
    if (_thisWeekendEvents == nil) _thisWeekendEvents = [[NSMutableArray alloc] init];
    else [_thisWeekendEvents removeAllObjects];
    
    if (_thisWeekEvents == nil) _thisWeekEvents = [[NSMutableArray alloc] init];
    else [_thisWeekEvents removeAllObjects];
    
    if (_nextWeekEvents == nil) _nextWeekEvents = [[NSMutableArray alloc] init];
    else [_nextWeekEvents removeAllObjects];
    
    if (_otherEvents == nil) _otherEvents = [[NSMutableArray alloc] init];
    else [_otherEvents removeAllObjects];
    
    for (Event *event in eventsArray) {
        if ([event.startTime longLongValue] >= [TimeSupport getTodayTimeFrameStartTimeInUnix] && [event.startTime longLongValue] < [TimeSupport getTodayTimeFrameStartTimeInUnix]) {
            [_todayEvents addObject:event];
        } else if ([event.startTime longLongValue] >= [TimeSupport getThisWeekendTimeFrameStartTimeInUnix] && [event.startTime longLongValue] < [TimeSupport getThisWeekendTimeFrameEndTimeInUnix]) {
            [_thisWeekendEvents addObject:event];
        } else if ([event.startTime longLongValue] >= [TimeSupport getThisWeekTimeFrameStartTimeInUnix] && [event.startTime longLongValue] < [TimeSupport getThisWeekTimeFrameEndTimeInUnix]) {
            [_thisWeekEvents addObject:event];
        } else if ([event.startTime longLongValue] >= [TimeSupport getNextWeekTimeFrameStartTimeInUnix] && [event.startTime longLongValue] < [TimeSupport getNextWeekTimeFrameEndTimeInUnix]) {
            [_nextWeekEvents addObject:event];
        } else {
            [_otherEvents addObject:event];
        }
    }
}

/**
 * Get the number of session to be display in the table view. 
 * This is equal to the number of event classes
 * @return integer number of sessions
 */
- (NSInteger) getNumberOfSections {
    return [[self getSectionTitlesArray] count];
}

/**
 * Get the title at given section index
 * @param section number
 * @return title string
 */
- (NSString *) getTitleAtSection:(NSInteger)sectionNumber {
    return [[self getSectionTitlesArray] objectAtIndex:sectionNumber];
}

/**
 * Get the events at a given section
 * @param section number
 * @return Array of Events
 */
- (NSArray *) getEventsAtSection:(NSInteger)sectionNumber {
    NSString *sectionTitle = [self getTitleAtSection:sectionNumber];

    if ([sectionTitle isEqualToString:TODAY_EVENTS_HEADER]) return _todayEvents;
    if ([sectionTitle isEqualToString:THIS_WEEKEND_EVENTS_HEADER]) return _thisWeekendEvents;
    if ([sectionTitle isEqualToString:THIS_WEEK_EVENTS_HEADER]) return _thisWeekEvents;
    if ([sectionTitle isEqualToString:NEXT_WEEK_EVENTS_HEADER]) return _nextWeekEvents;
    if ([sectionTitle isEqualToString:OTHER_EVENTS_HEADER]) return _otherEvents;
    
    return nil;
}

@end
