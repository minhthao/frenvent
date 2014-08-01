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
#import "PagedUserScrollView.h"
#import "FbUserInfoButtons.h"

@interface FbUserInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FbUserInfoRequestDelegate, UIAlertViewDelegate, PagedPhotoScrollViewDelegate, PagedEventScrollViewDelegate, PagedUserScrollViewDelegate, FbUserInfoButtonsDelegate>
- (IBAction)viewSegments:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *eventTable;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (weak, nonatomic) IBOutlet UISegmentedControl *viewSegmentControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
- (IBAction)shareClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *numMutualFriends;

@property (nonatomic, strong) NSString *targetUid;

@end
