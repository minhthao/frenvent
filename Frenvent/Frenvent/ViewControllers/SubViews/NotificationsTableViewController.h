//
//  NotificationsTableViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/12/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagedEventScrollView.h"
#import "EventParticipantView.h"
#import "EventRsvpRequest.h"

@interface NotificationsTableViewController : UITableViewController <PagedEventScrollViewDelegate, EventParticipantViewDelegate, UIActionSheetDelegate, EventRsvpRequestDelegate, UIAlertViewDelegate>

- (IBAction)rateAction:(id)sender;



@end
