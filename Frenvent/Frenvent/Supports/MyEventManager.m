//
//  MyEventManager.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "MyEventManager.h"
#import "Event.h"
#import "EventCoreData.h"

static NSString * const HEADER_UNREPLIED = @"Unreplied";
static NSString * const HEADER_REPLIED = @"Replied";
static NSString * const HEADER_PAST = @"History";

@interface MyEventManager()
@property (nonatomic, strong) NSArray *repliedEvents;
@property (nonatomic, strong) NSArray *unrepliedEvents;
@property (nonatomic, strong) NSArray *pastEvents;
@property (nonatomic, strong) NSMutableArray *headers;
@end

@implementation MyEventManager

#pragma mark - public methods
/**
 * Load the data for events
 */
-(void)loadData {
    self.repliedEvents = [EventCoreData getUserRepliedOngoingEvents];
    self.unrepliedEvents = [EventCoreData getUserUnrepliedOngoingEvents];
    self.pastEvents = [EventCoreData getUserPastEvents];
    self.headers = [[NSMutableArray alloc] init];
    if ([self.unrepliedEvents count] > 0) [self.headers addObject:HEADER_UNREPLIED];
    if ([self.repliedEvents count] > 0) [self.headers addObject:HEADER_REPLIED];
    if ([self.pastEvents count] > 0) [self.headers addObject:HEADER_PAST];
}

/**
 * get the title for the header in a particular section
 * @param section number
 * @return title
 */
-(NSString *)getTitleForHeaderInSection:(NSInteger)section {
    return [self.headers objectAtIndex:section];
}

/**
 * Get the number of session to be display in the table view.
 * This is equal to the number of event classes
 * @return integer number of sessions
 */
-(NSInteger)getNumberOfSections {
    return [[self headers] count];
}

/**
 * Get the number of rows for the given section
 * @param section number
 * @return number of row
 */
-(NSInteger)getNumberOfRowsInSection:(NSInteger)section {
    if ([[self getTitleForHeaderInSection:section] isEqualToString:HEADER_UNREPLIED])
        return [self.unrepliedEvents count];
    else if ([[self getTitleForHeaderInSection:section] isEqualToString:HEADER_REPLIED])
        return [self.repliedEvents count];
    else return [self.pastEvents count];

}

/**
 * Get the event at the given index path
 * @param index path
 * @return Event
 */
-(Event *)getEventAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self getTitleForHeaderInSection:indexPath.section] isEqualToString:HEADER_UNREPLIED])
        return [self.unrepliedEvents objectAtIndex:indexPath.row];
    else if ([[self getTitleForHeaderInSection:indexPath.section] isEqualToString:HEADER_REPLIED])
        return [self.repliedEvents objectAtIndex:indexPath.row];
    else return [self.pastEvents objectAtIndex:indexPath.row];
}

@end
