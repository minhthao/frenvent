//
//  EventManager.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/6/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventManager : NSObject

@property (nonatomic, strong) NSMutableArray *todayEvents;
@property (nonatomic, strong) NSMutableArray *thisWeekEvents;
@property (nonatomic, strong) NSMutableArray *thisWeekendEvents;
@property (nonatomic, strong) NSMutableArray *nextWeekEvents;
@property (nonatomic, strong) NSMutableArray *otherEvents;

- (void)setEvents:(NSArray *)eventsArray;
- (void)setEvents:(NSArray *)eventsArray withCurrentLocation:(CLLocation *)currentLocation;
- (void)setCurrentLocation:(CLLocation *)currentLocation;
- (NSInteger) getNumberOfSections;
- (NSString *) getTitleAtSection:(NSInteger)sectionNumber;
- (NSArray *) getEventsAtSection:(NSInteger)sectionNumber;
- (void)hideEventAtIndexPath:(NSIndexPath *)indexPath;
- (void)changeRsvpOfEventAtIndexPath:(NSIndexPath *)indexPath withRsvp:(NSString *)rsvp;
@end
