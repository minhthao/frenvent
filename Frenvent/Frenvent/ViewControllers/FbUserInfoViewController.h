//
//  FriendInfoViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FbUserInfoRequest.h"
#import "Friend.h"
#import "PagedPhotoScrollView.h"
#import "PagedEventScrollView.h"
#import "PagedFbUserScrollView.h"
#import "EventRsvpRequest.h"
#import "RecommendFbUserRequest.h"

@interface FbUserInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FbUserInfoRequestDelegate, UIAlertViewDelegate, PagedPhotoScrollViewDelegate, PagedEventScrollViewDelegate, PagedFbUserScrollViewDelegate,EventRsvpRequestDelegate, RecommendFbUserRequestDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
- (IBAction)shareClicked:(id)sender;

@property (nonatomic, strong) NSString *targetUid;

@end
