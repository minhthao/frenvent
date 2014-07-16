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

@implementation EventManager

#pragma mark - private method
/**
 * Get the title array for sections
 * @return Array of Title string
 */
- (NSMutableArray *)getSectionTitlesArray {
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    if ([_todayEvents count] > 0) [sectionTitles addObject:TODAY_EVENTS_HEADER];
    if ([_thisWeekEvents count] > 0) [sectionTitles addObject:THIS_WEEK_EVENTS_HEADER];
    if ([_thisWeekendEvents count] > 0) [sectionTitles addObject:THIS_WEEKEND_EVENTS_HEADER];
    if ([_nextWeekEvents count] > 0) [sectionTitles addObject:NEXT_WEEK_EVENTS_HEADER];
    if ([_otherEvents count] > 0) [sectionTitles addObject:OTHER_EVENTS_HEADER];
    
    return sectionTitles;
}

/**
 * Reset all the event arrays to empty state
 */
- (void)resetEventArrays {
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
}

/**
 * Set the date category of the event
 * @param Event
 */
- (void)setEventCategory:(Event *)event {
    if ([event.startTime longLongValue] >= [TimeSupport getTodayTimeFrameStartTimeInUnix] && [event.startTime longLongValue] < [TimeSupport getTodayTimeFrameEndTimeInUnix]) {
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

#pragma mark - public methods
/**
 * Set the events
 * This will classified the events into 5 separate category by time
 * @param Array of Event
 */
- (void)setEvents:(NSArray *)eventsArray {
    [self resetEventArrays];
    for (Event *event in eventsArray) {
        [self setEventCategory:event];
    }
}

/**
 * Set the events and compute the distance using the current location
 * This will classified the events into 5 separate category by time
 * @param Array of Event
 * @param CLLocation
 */
- (void)setEvents:(NSArray *)eventsArray withCurrentLocation:(CLLocation *)currentLocation {
    [self resetEventArrays];
    for (Event *event in eventsArray) {
        [event computeDistanceToCurrentLocation:currentLocation];
        [self setEventCategory:event];
    }
}

/**
 * Set the current location to compute the distance of each event
 * @param CLLocation
 */
- (void)setCurrentLocation:(CLLocation *)currentLocation {
    for (Event *event in _todayEvents) {
        [event computeDistanceToCurrentLocation:currentLocation];
    }
    
    for (Event *event in _thisWeekendEvents) {
        [event computeDistanceToCurrentLocation:currentLocation];
    }
    
    for (Event *event in _thisWeekEvents) {
        [event computeDistanceToCurrentLocation:currentLocation];
    }
    
    for (Event *event in _nextWeekEvents) {
        [event computeDistanceToCurrentLocation:currentLocation];
    }
    
    for (Event *event in _otherEvents) {
        [event computeDistanceToCurrentLocation:currentLocation];
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

/**
 * Hide the event at a given index path
 * @param index path
 */
- (void)hideEventAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = [self getTitleAtSection:indexPath.section];
    
    if ([sectionTitle isEqualToString:TODAY_EVENTS_HEADER]) [_todayEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:THIS_WEEKEND_EVENTS_HEADER]) [_thisWeekendEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:THIS_WEEK_EVENTS_HEADER]) [_thisWeekEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:NEXT_WEEK_EVENTS_HEADER]) [_nextWeekEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:OTHER_EVENTS_HEADER]) [_otherEvents removeObjectAtIndex:indexPath.row];
}

@end
