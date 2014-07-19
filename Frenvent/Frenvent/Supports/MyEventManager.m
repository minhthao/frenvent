//
//  MyEventManager.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "MyEventManager.h"
#import "Event.h"

static NSString * const UNREPLIED_EVENTS_HEADER = @"UNREPLIED";
static NSString * const REPLIED_EVENTS_HEADER = @"REPLIED";

@implementation MyEventManager
#pragma mark - private method
/**
 * Get the title array for sections
 * @return Array of Title string
 */
- (NSMutableArray *)getSectionTitlesArray {
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    if ([_unrepliedEvents count] > 0) [sectionTitles addObject:UNREPLIED_EVENTS_HEADER];
    if ([_repliedEvents count] > 0) [sectionTitles addObject:REPLIED_EVENTS_HEADER];
    
    return sectionTitles;
}

#pragma mark - public methods
/**
 * Set the replied and unreplied events
 * @param replied event
 * @param unreplied events
 */
- (void)setRepliedEvents:(NSArray *)myRepliedEvents unrepliedEvents:(NSArray *)myUnrepliedEvents {
    _repliedEvents = myRepliedEvents;
    _unrepliedEvents = myUnrepliedEvents;
}

/**
 * Set the replied and unreplied events, and compute the distance to the current location
 * @param replied event
 * @param unreplied events
 * @param current location
 */
- (void)setRepliedEvents:(NSArray *)repliedEvent unrepliedEvents:(NSArray *)unrepliedEvents withCurrentLocation:(CLLocation *)currentLocation {
    [self setRepliedEvents:repliedEvent unrepliedEvents:unrepliedEvents];
    if (currentLocation != nil) [self setCurrentLocation:currentLocation];
}

/**
 * Set the current location to compute the distance of each event
 * @param CLLocation
 */
- (void)setCurrentLocation:(CLLocation *)currentLocation {
    for (Event *event in _repliedEvents) {
        [event computeDistanceToCurrentLocation:currentLocation];
    }
    
    for (Event *event in _unrepliedEvents) {
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
    
    if ([sectionTitle isEqualToString:UNREPLIED_EVENTS_HEADER]) return _unrepliedEvents;
    if ([sectionTitle isEqualToString:REPLIED_EVENTS_HEADER]) return _repliedEvents;
    
    return nil;
}

@end
