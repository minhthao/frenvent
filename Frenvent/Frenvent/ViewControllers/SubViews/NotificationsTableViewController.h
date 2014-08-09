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

@interface NotificationsTableViewController : UITableViewController <PagedEventScrollViewDelegate, EventParticipantViewDelegate>

@end
