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
    }
    return self;
}

- (void)setEvents:(NSArray *)events {
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    [self.loadingSpinner stopAnimating];
    CGSize scrollViewSize = self.frame.size;
    
    if ([events count] > 0) {
        self.contentSize = CGSizeMake(scrollViewSize.width * [events count], scrollViewSize.height);
        //CGSizeMake(scrollViewSize.width * [events count], scrollViewSize.height);
        for (int i = 0; i < [events count]; i++) {
            Event *event = [events objectAtIndex:i];
            CGRect eventFrame = CGRectMake(scrollViewSize.width * i + 3 , 1, scrollViewSize.width - 6, scrollViewSize.height - 2);
            ScrollEvent *eventView = [[ScrollEvent alloc] initWithFrame:eventFrame];
            eventView.delegate = self;
            [eventView setViewEvent:event];
            [self addSubview:eventView];
        }
    }
}

-(void)eventClicked:(Event *)event {
    [self.delegate eventClicked:event];
}

-(void)eventRsvpButtonClicked:(Event *)event withButton:(UIButton *)rsvpButton{
    [self.delegate eventRsvpButtonClicked:event withButton:rsvpButton];
}
@end
