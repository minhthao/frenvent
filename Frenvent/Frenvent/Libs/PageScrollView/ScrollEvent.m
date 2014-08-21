//
//  ScrollEvent.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "ScrollEvent.h"
#import "MyColor.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "TimeSupport.h"

@interface ScrollEvent()
@property (nonatomic, strong) UIImageView *cover;
@property (nonatomic, strong) UILabel *eventIndexLabel;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *location;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UIButton *eventRsvpButtonView;
@property (nonatomic, strong) Event *event;
@end

@implementation ScrollEvent

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setMasksToBounds:NO];
        [self.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
        [self.layer setShadowRadius:1];
        [self.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
        [self.layer setShadowOpacity:0.35f];
        [self.layer setBorderWidth:0.5f];
        [self.layer setBorderColor:[[MyColor eventCellButtonsContainerBorderColor] CGColor]];
        
        UITapGestureRecognizer *eventTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEventTap:)];
        [self setUserInteractionEnabled:true];
        [self addGestureRecognizer:eventTap];
        
        self.cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 60)];
        self.cover.clipsToBounds = true;
        self.cover.contentMode = UIViewContentModeScaleAspectFill;
        self.cover.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.cover];
        
        self.eventIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
        self.eventIndexLabel.backgroundColor = [UIColor clearColor];
        self.eventIndexLabel.textColor =[UIColor whiteColor];
        self.eventIndexLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        self.eventIndexLabel.textAlignment = NSTextAlignmentCenter;
        self.eventIndexLabel.shadowColor = [UIColor blackColor];
        self.eventIndexLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:self.eventIndexLabel];
        
        CGRect detailFrame = CGRectMake(0, frame.size.height - 60, frame.size.width, 60);
        UIView *eventDetailContainerView = [[UIView alloc] initWithFrame:detailFrame];
        eventDetailContainerView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        [self addSubview:eventDetailContainerView];
        
        self.eventRsvpButtonView = [[UIButton alloc] initWithFrame:CGRectMake(detailFrame.size.width - 50, 10, 40, 40)];
        [self.eventRsvpButtonView setUserInteractionEnabled:true];
        [self.eventRsvpButtonView.layer setMasksToBounds:YES];
        [self.eventRsvpButtonView.layer setBorderColor:[[MyColor eventCellButtonsContainerBorderColor] CGColor]];
        [self.eventRsvpButtonView.layer setCornerRadius:3.0f];
        [self.eventRsvpButtonView.layer setBorderWidth:1];
        
        [self.eventRsvpButtonView.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
        [self.eventRsvpButtonView.layer setShadowRadius:1.0f];
        [self.eventRsvpButtonView.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
        [self.eventRsvpButtonView.layer setShadowOpacity:0.5];
        
        [self.eventRsvpButtonView setBackgroundImage:[UIImage imageNamed:@"ScrollViewOngoingEventRsvpButtonStateNormal"] forState:UIControlStateNormal];
        [self.eventRsvpButtonView setBackgroundImage:[UIImage imageNamed:@"ScrollViewOngoingEventRsvpButtonStateDisable"] forState:UIControlStateDisabled];
        [self.eventRsvpButtonView setBackgroundImage:[UIImage imageNamed:@"ScrollViewOngoingEventRsvpButtonStateHighlight"] forState:UIControlStateHighlighted];
        
        [self.eventRsvpButtonView addTarget:self action:@selector(handleEventRsvp:) forControlEvents:UIControlEventTouchUpInside];
        [eventDetailContainerView addSubview:self.eventRsvpButtonView];
        
        CGRect infoFrame = CGRectMake(8, 2, detailFrame.size.width - 76, 56);
        UIView *eventInfoContainerView = [[UIView alloc] initWithFrame:infoFrame];
        [eventDetailContainerView addSubview:eventInfoContainerView];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, infoFrame.size.width, 20)];
        self.title.textColor = [UIColor darkTextColor];
        self.title.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
        [eventInfoContainerView addSubview:self.title];
        
        self.location = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, infoFrame.size.width, 17)];
        self.location.textColor = [UIColor grayColor];
        self.location.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        [eventInfoContainerView addSubview:self.location];
    
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, infoFrame.size.width, 18)];
        self.time.textColor = [UIColor darkGrayColor];
        self.time.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        [eventInfoContainerView addSubview:self.time];
    }
    return self;
}

-(void)setViewEvent:(Event *)event {
    self.event = event;
    if ([event.cover length] > 0)
        [self.cover setImageWithURL:[NSURL URLWithString:event.cover] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    else [self.cover setImageWithURL:[NSURL URLWithString:event.picture] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
    self.title.text = event.name;
    self.location.text = event.location;
    self.time.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    
    if ([event.rsvp isEqualToString:RSVP_ATTENDING] || [event.rsvp isEqualToString:RSVP_UNSURE] || ![event canRsvp])
        [self.eventRsvpButtonView setEnabled:false];
}

-(void)handleEventTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate eventClicked:self.event];
}

-(void)handleEventRsvp:(UIButton *)sender {
    [self.delegate eventRsvpButtonClicked:self.event withButton:self.eventRsvpButtonView];
}

@end
