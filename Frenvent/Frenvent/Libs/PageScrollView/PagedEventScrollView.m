//
//  PagedEventScrollView.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedEventScrollView.h"
#import "ScrollEvent.h"

@implementation PagedEventScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setEvents:(NSArray *)events {
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    CGSize scrollViewSize = self.frame.size;
    self.contentSize = CGSizeMake(scrollViewSize.width * [events count], scrollViewSize.height);
    for (int i = 0; i < [events count]; i++) {
        Event *event = [events objectAtIndex:i];
        CGRect eventFrame = CGRectMake(scrollViewSize.width * i, 0, scrollViewSize.width, scrollViewSize.height);
        ScrollEvent *eventView = [[ScrollEvent alloc] initWithFrame:eventFrame];
        eventView.delegate = self;
        [eventView setPageIndex:i+1 pageCount:(int)[events count]];
        [eventView setViewEvent:event];
        [self addSubview:eventView];
    }
    self.pageControl.numberOfPages = [events count];
}

-(void)eventClicked:(Event *)event {
    [self.delegate eventClicked:event];
}

-(void)eventRsvpButtonClicked:(Event *)event {
    [self.delegate eventRsvpButtonClicked:event];
}
@end
