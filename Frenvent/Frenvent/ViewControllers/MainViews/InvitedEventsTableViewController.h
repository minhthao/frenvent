//
//  InvitedEventsTableViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/8/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEventsRequest.h"
#import "EventRsvpRequest.h"
#import "ShareEventRequest.h"

@interface InvitedEventsTableViewController : UITableViewController <MyEventsRequestDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)doRefresh:(id)sender;

@end
