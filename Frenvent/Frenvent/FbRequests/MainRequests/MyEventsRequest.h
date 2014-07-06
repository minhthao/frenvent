//
//  MyEventsRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyEventsRequestDelegate <NSObject>
@optional
- (void)notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents;
@end

@interface MyEventsRequest : NSObject

@property (nonatomic, weak) id <MyEventsRequestDelegate> delegate;

- (void) initMyEvents; //all events
- (void) refreshMyEvents;  //only future events
- (void) updateBackgroundMyEvents;  //only future events 

@end