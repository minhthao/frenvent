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

@interface EventDetailViewController : UITableViewController <EventDetailsRequestDelegate, UIAlertViewDelegate, DbEventsRequestDelegate, ShareEventRequestDelegate, EventRsvpRequestDelegate, UIActionSheetDelegate,  EventParticipantViewDelegate, EventDetailRecommendUserRequestDelegate, PagedUserScrollViewDelegate>

@property (nonatomic, strong) NSString *eid;
@property (nonatomic) BOOL isModal;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
- (IBAction)shareAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *headerView;



@end
