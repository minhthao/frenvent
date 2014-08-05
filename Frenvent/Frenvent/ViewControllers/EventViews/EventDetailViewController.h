//
//  EventDetailViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventDetailsRequest.h"
#import "DbEventsRequest.h"
#import "ShareEventRequest.h"
#import "EventRsvpRequest.h"

@interface EventDetailViewController : UIViewController <EventDetailsRequestDelegate, UIAlertViewDelegate, DbEventsRequestDelegate, ShareEventRequestDelegate, EventRsvpRequestDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSString *eid;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
- (IBAction)shareAction:(id)sender;


@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *rsvpStatus;

@end
