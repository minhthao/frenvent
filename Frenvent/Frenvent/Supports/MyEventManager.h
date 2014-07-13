//
//  MyEventManager.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEventManager : NSObject

@property (nonatomic, strong) NSArray *repliedEvents;
@property (nonatomic, strong) NSArray *unrepliedEvents;


- (void)setRepliedEvents:(NSArray *)repliedEvent unrepliedEvents:(NSArray *)unrepliedEvents;
- (void)setRepliedEvents:(NSArray *)repliedEvent unrepliedEvents:(NSArray *)unrepliedEvents withCurrentLocation:(CLLocation *)currentLocation;
- (void)setCurrentLocation:(CLLocation *)currentLocation;
- (NSInteger) getNumberOfSections;
- (NSString *) getTitleAtSection:(NSInteger)sectionNumber;
- (NSArray *) getEventsAtSection:(NSInteger)sectionNumber;

@end
