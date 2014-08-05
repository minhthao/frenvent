//
//  ScrollEvent.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@protocol ScrollEventDelegate <NSObject>
@optional
- (void)eventClicked:(Event *)event;
- (void)eventRsvpButtonClicked:(Event *)event withButton:(UIButton *)rsvpButton;
@end

@interface ScrollEvent : UIView 

@property (nonatomic, weak) id <ScrollEventDelegate> delegate;

-(void)setViewEvent:(Event *)event;
-(void)setPageIndex:(int)index pageCount:(int)pageCount;

@end
