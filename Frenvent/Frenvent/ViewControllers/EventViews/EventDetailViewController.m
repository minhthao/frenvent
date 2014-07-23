//
//  EventDetailViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventDetailsRequest.h"
#import "UIImageView+AFNetworking.h"
#import "EventDetail.h"

@interface EventDetailViewController ()

@property (nonatomic, strong) EventDetailsRequest *eventDetailsRequest;

@end

@implementation EventDetailViewController

EventDetail *completeEventDetail;

#pragma mark - initiate with delegates
- (EventDetailsRequest *)eventDetailsRequest {
    if (_eventDetailsRequest == nil) {
        _eventDetailsRequest = [[EventDetailsRequest alloc] init];
        _eventDetailsRequest.delegate = self;
    }
    return _eventDetailsRequest;
}

- (void)notifyEventDidNotExist {
    
}

- (void)notifyEventDetailsQueryFail {
    
}

- (void)notifyEventDetailsQueryCompletedWithResult:(EventDetail *)eventDetail {
    completeEventDetail = eventDetail;
    self.eventTitle.text = completeEventDetail.name;
    if ([completeEventDetail.cover length] > 0)
        [self.cover setImageWithURL:[NSURL URLWithString:completeEventDetail.cover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.eid != nil) {
        [[self eventDetailsRequest] queryEventDetail:self.eid];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
