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
#import "Friend.h"

NSInteger const FILTER_TYPE_WITHIN_FIVE_MILE = 0;
NSInteger const FILTER_TYPE_WITHIN_TWENTY_FIVE_MILE = 1;
NSInteger const FILTER_TYPE_WITHIN_FIFTY_MILE = 2;
NSInteger const FILTER_TYPE_DEFAULT = 3;

static NSString * const RECOMMENDATION_EVENTS_HEADER = @"Recommendation";
static NSString * const TODAY_EVENTS_HEADER = @"Today";
static NSString * const THIS_WEEK_EVENTS_HEADER = @"This week";
static NSString * const THIS_WEEKEND_EVENTS_HEADER = @"This weekend";
static NSString * const NEXT_WEEK_EVENTS_HEADER = @"Next week";
static NSString * const OTHER_EVENTS_HEADER = @"Other";

@interface EventManager()

@property (nonatomic) int64_t todayStartTime;
@property (nonatomic) int64_t todayEndTime;
@property (nonatomic) int64_t thisWeekendStartTime;
@property (nonatomic) int64_t thisWeekendEndTime;
@property (nonatomic) int64_t thisWeekStartTime;
@property (nonatomic) int64_t thisWeekEndTime;
@property (nonatomic) int64_t nextWeekStartTime;
@property (nonatomic) int64_t nextWeekEndTime;

@end

@implementation EventManager

-(id)init {
    self = [super init];
    if (self) {
        self.todayStartTime = [TimeSupport getTodayTimeFrameStartTimeInUnix];
        self.todayEndTime = [TimeSupport getTodayTimeFrameEndTimeInUnix];
        self.thisWeekendStartTime = [TimeSupport getThisWeekendTimeFrameStartTimeInUnix];
        self.thisWeekendEndTime = [TimeSupport getThisWeekendTimeFrameEndTimeInUnix];
        self.thisWeekStartTime = [TimeSupport getThisWeekTimeFrameStartTimeInUnix];
        self.thisWeekEndTime = [TimeSupport getThisWeekTimeFrameEndTimeInUnix];
        self.nextWeekStartTime = [TimeSupport getNextWeekTimeFrameStartTimeInUnix];
        self.nextWeekEndTime = [TimeSupport getNextWeekTimeFrameEndTimeInUnix];
    }
    return self;
}

#pragma mark - private method
/**
 * Check if an event match filtered type
 * @param event
 * @return boolean
 */
-(BOOL)matchFilterType:(Event *)event {
    return ((((self.filterType == FILTER_TYPE_WITHIN_FIVE_MILE && [event.distance doubleValue] <= 5) ||
            (self.filterType == FILTER_TYPE_WITHIN_TWENTY_FIVE_MILE && [event.distance doubleValue] <= 25) ||
            (self.filterType == FILTER_TYPE_WITHIN_FIFTY_MILE && [event.distance doubleValue] <= 50)) &&
            [event.distance doubleValue] != 0) || self.filterType == FILTER_TYPE_DEFAULT);
}

/**
 * Get the title array for sections
 * @return Array of Title string
 */
- (NSMutableArray *)getSectionTitlesArray {
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    if ([_recommendedEvents count] > 0) [sectionTitles addObject:RECOMMENDATION_EVENTS_HEADER];
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
    if (_recommendedEvents == nil) _recommendedEvents = [[NSMutableArray alloc] init];
    else [_recommendedEvents removeAllObjects];
    
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
    event.score = 0;
    BOOL shouldBeCategorize = false;
    
    for (Friend *friend in event.friendsInterested) {
        if ([friend.favorite boolValue]) {
            shouldBeCategorize = true;
            break;
        }
    }
    
    if (shouldBeCategorize) {
        int64_t startTime = [event.startTime longLongValue];
        
        if (startTime >= self.todayStartTime && startTime < self.todayEndTime) {
            [_todayEvents addObject:event];
            event.score += 4;
        } else if (startTime >= self.thisWeekendStartTime && startTime < self.thisWeekendEndTime) {
            [_thisWeekendEvents addObject:event];
            event.score += 3;
        } else if (startTime >= self.thisWeekStartTime && startTime < self.thisWeekEndTime) {
            [_thisWeekEvents addObject:event];
            event.score += 2;
        } else if (startTime >= self.nextWeekStartTime && startTime < self.nextWeekEndTime) {
            [_nextWeekEvents addObject:event];
            event.score += 1;
        } else [_otherEvents addObject:event];
        
        if (event.friendsInterested.count >= 10) event.score += 4;
        else if (event.friendsInterested.count >= 5) event.score += 3;
        else if (event.friendsInterested.count >= 2) event.score += 2;
        
        double distance = [event.distance doubleValue];
        if (event.distance != 0) {
            if (distance <= 10) event.score += 5;
            else if (distance <= 25) event.score += 3;
            else if (distance <= 50) event.score += 1;
        }
        
        [self checkAndAddEventToRecommendation:event];
    } else [_otherEvents addObject:event];
}

/**
 * check whether we should add the event to recommendation
 * @param event
 */
-(void)checkAndAddEventToRecommendation:(Event *)event {
    if ([_recommendedEvents count] == 0) {
        [_recommendedEvents addObject:event];
    } else if ([_recommendedEvents count] == 1) {
        if (((Event *)[_recommendedEvents objectAtIndex:0]).score >= event.score) [_recommendedEvents addObject:event];
        else [_recommendedEvents insertObject:event atIndex:0];
    } else if ([_recommendedEvents count] == 2) {
        double firstHighestScore = ((Event *)[_recommendedEvents objectAtIndex:0]).score;
        double secondHighestScore = ((Event *)[_recommendedEvents objectAtIndex:1]).score;
        if (firstHighestScore < event.score) [_recommendedEvents insertObject:event atIndex:0];
        else if (secondHighestScore < event.score) [_recommendedEvents addObject:event];
    } else if ([_recommendedEvents count] == 3) {
        double firstHighestScore = ((Event *)[_recommendedEvents objectAtIndex:0]).score;
        double secondHighestScore = ((Event *)[_recommendedEvents objectAtIndex:1]).score;
        double thirdHighestScore = ((Event *)[_recommendedEvents objectAtIndex:2]).score;
        if (firstHighestScore < event.score) {
            [_recommendedEvents removeObjectAtIndex:2];
            [_recommendedEvents insertObject:event atIndex:0];
        } else if (secondHighestScore < event.score) {
            [_recommendedEvents removeObjectAtIndex:2];
            [_recommendedEvents insertObject:event atIndex:1];
        } else if (thirdHighestScore < event.score) {
            [_recommendedEvents removeObjectAtIndex:2];
            [_recommendedEvents addObject:event];
        }
    }
}

/**
 * Remove all the event recommended out of the other list
 */
-(void)removeEventsFromRecommendedListFromOtherList {
    if (self.recommendedEvents != nil) {
        for (Event *event in self.recommendedEvents) {
            BOOL shouldBeCategorize = false;
            
            for (Friend *friend in event.friendsInterested) {
                if ([friend.favorite boolValue]) {
                    shouldBeCategorize = true;
                    break;
                }
            }
            
            if (shouldBeCategorize) {
                int64_t startTime = [event.startTime longLongValue];
                
                if (startTime >= self.todayStartTime && startTime < self.todayEndTime) {
                    for (int i = 0; i < [self.todayEvents count]; i++) {
                        if ([event.eid isEqualToString:((Event *)[self.todayEvents objectAtIndex:i]).eid]) {
                            [self.todayEvents removeObjectAtIndex:i];
                            break;
                        }
                    }
                } else if (startTime >= self.thisWeekendStartTime && startTime < self.thisWeekendEndTime) {
                    for (int i = 0; i < [self.thisWeekendEvents count]; i++) {
                        if ([event.eid isEqualToString:((Event *)[self.thisWeekendEvents objectAtIndex:i]).eid]) {
                            [self.thisWeekendEvents removeObjectAtIndex:i];
                            break;
                        }
                    }
                } else if (startTime >= self.thisWeekStartTime && startTime < self.thisWeekEndTime) {
                    for (int i = 0; i < [self.thisWeekEvents count]; i++) {
                        if ([event.eid isEqualToString:((Event *)[self.thisWeekEvents objectAtIndex:i]).eid]) {
                            [self.thisWeekEvents removeObjectAtIndex:i];
                            break;
                        }
                    }
                } else if (startTime >= self.nextWeekStartTime && startTime < self.nextWeekEndTime) {
                    for (int i = 0; i < [self.nextWeekEvents count]; i++) {
                        if ([event.eid isEqualToString:((Event *)[self.nextWeekEvents objectAtIndex:i]).eid]) {
                            [self.nextWeekEvents removeObjectAtIndex:i];
                            break;
                        }
                    }
                } else {
                    for (int i = 0; i < [self.otherEvents count]; i++) {
                        if ([event.eid isEqualToString:((Event *)[self.otherEvents objectAtIndex:i]).eid]) {
                            [self.otherEvents removeObjectAtIndex:i];
                            break;
                        }
                    }
                }
                
            } else {
                for (int i = 0; i < [self.otherEvents count]; i++) {
                    if ([event.eid isEqualToString:((Event *)[self.otherEvents objectAtIndex:i]).eid]) {
                        [self.otherEvents removeObjectAtIndex:i];
                        break;
                    }
                }
            }
        }
    }
}

#pragma mark - public methods
/**
 * Set the events
 * This will classified the events into 5 separate category by time
 * @param Array of Event
 */
- (void)setEvents:(NSArray *)eventsArray {
    self.eventsArray = eventsArray;
    [self resetEventArrays];
    for (Event *event in self.eventsArray) {
        if ([self matchFilterType:event]) [self setEventCategory:event];
    }
    [self removeEventsFromRecommendedListFromOtherList];
}

/**
 * Set the events and compute the distance using the current location
 * This will classified the events into 5 separate category by time
 * @param Array of Event
 * @param CLLocation
 */
- (void)setEvents:(NSArray *)eventsArray withCurrentLocation:(CLLocation *)currentLocation {
    self.eventsArray = eventsArray;
    [self resetEventArrays];
    for (Event *event in self.eventsArray) {
        [event computeDistanceToCurrentLocation:currentLocation];
        if ([self matchFilterType:event]) [self setEventCategory:event];
    }
    [self removeEventsFromRecommendedListFromOtherList];
}

/**
 * Set the current location to compute the distance of each event
 * @param CLLocation
 */
- (void)setCurrentLocation:(CLLocation *)currentLocation {
    [self resetEventArrays];
    for (Event *event in self.eventsArray) {
        [event computeDistanceToCurrentLocation:currentLocation];
        if ([self matchFilterType:event]) [self setEventCategory:event];
    }
    [self removeEventsFromRecommendedListFromOtherList];
}

/**
 * Filter the event using a specify filter type
 * @param filter type
 */
- (void)filterEvent:(NSInteger)filterType {
    self.filterType = filterType;
    [self resetEventArrays];
    for (Event *event in self.eventsArray) {
        if ([self matchFilterType:event]) [self setEventCategory:event];
    }
    [self removeEventsFromRecommendedListFromOtherList];
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

    if ([sectionTitle isEqualToString:RECOMMENDATION_EVENTS_HEADER]) return _recommendedEvents;
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
    
    if ([sectionTitle isEqualToString:RECOMMENDATION_EVENTS_HEADER]) [_recommendedEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:TODAY_EVENTS_HEADER]) [_todayEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:THIS_WEEKEND_EVENTS_HEADER]) [_thisWeekendEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:THIS_WEEK_EVENTS_HEADER]) [_thisWeekEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:NEXT_WEEK_EVENTS_HEADER]) [_nextWeekEvents removeObjectAtIndex:indexPath.row];
    if ([sectionTitle isEqualToString:OTHER_EVENTS_HEADER]) [_otherEvents removeObjectAtIndex:indexPath.row];
}

/**
 * Change the rsvp of the event at a given index path
 * @param index path
 */
- (void)changeRsvpOfEventAtIndexPath:(NSIndexPath *)indexPath withRsvp:(NSString *)rsvp{
    NSString *sectionTitle = [self getTitleAtSection:indexPath.section];
    
    if ([sectionTitle isEqualToString:RECOMMENDATION_EVENTS_HEADER]) ((Event *)[_recommendedEvents objectAtIndex:indexPath.row]).rsvp = rsvp;
    if ([sectionTitle isEqualToString:TODAY_EVENTS_HEADER]) ((Event *)[_todayEvents objectAtIndex:indexPath.row]).rsvp = rsvp;
    if ([sectionTitle isEqualToString:THIS_WEEKEND_EVENTS_HEADER]) ((Event *)[_thisWeekendEvents objectAtIndex:indexPath.row]).rsvp = rsvp;
    if ([sectionTitle isEqualToString:THIS_WEEK_EVENTS_HEADER]) ((Event *)[_thisWeekEvents objectAtIndex:indexPath.row]).rsvp = rsvp;
    if ([sectionTitle isEqualToString:NEXT_WEEK_EVENTS_HEADER]) ((Event *)[_nextWeekEvents objectAtIndex:indexPath.row]).rsvp = rsvp;
    if ([sectionTitle isEqualToString:OTHER_EVENTS_HEADER]) ((Event *)[_otherEvents objectAtIndex:indexPath.row]).rsvp = rsvp;

}

@end
