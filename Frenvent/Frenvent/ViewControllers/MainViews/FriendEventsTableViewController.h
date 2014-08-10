//
//  FriendEventsViewControllerTableViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/6/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendEventsRequest.h"
#import "EventRsvpRequest.h"
#import "ShareEventRequest.h"

@interface FriendEventsTableViewController : UITableViewController <CLLocationManagerDelegate, FriendEventsRequestDelegate, UIActionSheetDelegate, EventRsvpRequestDelegate, ShareEventRequestDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)doRefresh:(id)sender;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
- (IBAction)doFilter:(id)sender;



@end
