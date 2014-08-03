//
//  EventDetailViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventDetailsRequest.h"

@interface EventDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EventDetailsRequestDelegate>

@property (nonatomic, strong) NSString *eid;

@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *rsvpLabel;

@end
