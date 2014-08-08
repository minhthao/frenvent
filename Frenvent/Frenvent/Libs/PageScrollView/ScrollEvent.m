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
        eventDetailContainerView.backgroundColor = [MyColor eventCellButtonNormalBackgroundColor];
        [self addSubview:eventDetailContainerView];
        
        self.eventRsvpButtonView = [[UIButton alloc] initWithFrame:CGRectMake(detailFrame.size.width - 50, 10, 40, 40)];
        [self.eventRsvpButtonView setUserInteractionEnabled:true];
        [self.eventRsvpButtonView.layer setMasksToBounds:NO];
        [self.eventRsvpButtonView.layer setBorderColor:[[MyColor eventCellButtonsContainerBorderColor] CGColor]];
        [self.eventRsvpButtonView.layer setCornerRadius:3.0f];
        [self.eventRsvpButtonView.layer setBorderWidth:1];
        
        [self.eventRsvpButtonView.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
        [self.eventRsvpButtonView.layer setShadowRadius:2.0f];
        [self.eventRsvpButtonView.layer setShadowOffset:CGSizeMake(1, 1)];
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
        self.title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16];
        [eventInfoContainerView addSubview:self.title];
        
        self.location = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, infoFrame.size.width, 15)];
        self.location.textColor = [UIColor grayColor];
        self.location.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        [eventInfoContainerView addSubview:self.location];
    
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, infoFrame.size.width, 15)];
        self.time.textColor = [UIColor grayColor];
        self.time.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
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

-(void)setPageIndex:(int)index pageCount:(int)pageCount {
    self.eventIndexLabel.text = [NSString stringWithFormat:@"%d of %d", index, pageCount];
}

-(void)handleEventTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate eventClicked:self.event];
}

-(void)handleEventRsvp:(UIButton *)sender {
    [self.delegate eventRsvpButtonClicked:self.event withButton:self.eventRsvpButtonView];
}

@end
