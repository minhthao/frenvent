//
//  PagedEventScrollView.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedScrollView.h"
#import "Event.h"
#import "ScrollEvent.h"

@protocol PagedEventScrollViewDelegate <NSObject>
@optional
- (void)eventClicked:(Event *)event;
- (void)eventRsvpButtonClicked:(Event *)event;
@end

@interface PagedEventScrollView : PagedScrollView <ScrollEventDelegate>

@property (nonatomic, weak) id <PagedEventScrollViewDelegate> delegate;
- (void)setEvents:(NSArray *)events;

@end
