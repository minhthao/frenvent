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
        self.backgroundColor = [UIColor lightGrayColor];
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:2];

        UITapGestureRecognizer *eventTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEventTap:)];
        [self setUserInteractionEnabled:true];
        [self addGestureRecognizer:eventTap];
        
        self.cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 75)];
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
        
        CGRect detailFrame = CGRectMake(0, frame.size.height - 75, frame.size.width, 75);
        UIView *eventDetailContainerView = [[UIView alloc] initWithFrame:detailFrame];
        eventDetailContainerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [eventDetailContainerView.layer setBorderColor:[[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0] CGColor]];
        [eventDetailContainerView.layer setBorderWidth:0.8];
        [self addSubview:eventDetailContainerView];
        
        self.eventRsvpButtonView = [[UIButton alloc] initWithFrame:CGRectMake(detailFrame.size.width - 60, 0, 60, 75)];
        [self.eventRsvpButtonView setUserInteractionEnabled:true];
        
        [self.eventRsvpButtonView setBackgroundImage:[UIImage imageNamed:@"ScrollViewOngoingEventRsvpButtonStateNormal"] forState:UIControlStateNormal];
        [self.eventRsvpButtonView setBackgroundImage:[UIImage imageNamed:@"ScrollViewOngoingEventRsvpButtonStateDisable"] forState:UIControlStateDisabled];
        
        [self.eventRsvpButtonView addTarget:self action:@selector(handleEventRsvp:) forControlEvents:UIControlEventTouchUpInside];
        [eventDetailContainerView addSubview:self.eventRsvpButtonView];
        
        CGRect infoFrame = CGRectMake(10, 10, detailFrame.size.width - 85, 60);
        UIView *eventInfoContainerView = [[UIView alloc] initWithFrame:infoFrame];
        [eventDetailContainerView addSubview:eventInfoContainerView];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, infoFrame.size.width, 18)];
        self.title.textColor = [UIColor colorWithRed:23/255.0 green:23/255.0 blue:23/255.0 alpha:1.0];
        self.title.font = [UIFont fontWithName:@"SourceSansPro-Semibold" size:14];
        [eventInfoContainerView addSubview:self.title];
        
        self.location = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, infoFrame.size.width, 18)];
        self.location.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
        self.location.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:14];
        [eventInfoContainerView addSubview:self.location];
    
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, infoFrame.size.width, 18)];
        self.time.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
        self.time.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:14];
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
