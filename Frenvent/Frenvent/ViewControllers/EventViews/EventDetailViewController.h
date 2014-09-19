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
#import "EventParticipantView.h"
#import "EventDetailRecommendUserRequest.h"
#import "PagedUserScrollView.h"

@interface EventDetailViewController : UIViewController <EventDetailsRequestDelegate, UIAlertViewDelegate, DbEventsRequestDelegate, ShareEventRequestDelegate, EventRsvpRequestDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, EventParticipantViewDelegate, EventDetailRecommendUserRequestDelegate, PagedUserScrollViewDelegate>

@property (nonatomic, strong) NSString *eid;
@property (nonatomic) BOOL isModal;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
- (IBAction)shareAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (weak, nonatomic) IBOutlet UITableView *mainView;


@property (weak, nonatomic) IBOutlet UIView *headerView;



@end
