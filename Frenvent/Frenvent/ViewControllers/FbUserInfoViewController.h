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

@interface FbUserInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FbUserInfoRequestDelegate, UIAlertViewDelegate, PagedPhotoScrollViewDelegate, PagedEventScrollViewDelegate, UIGestureRecognizerDelegate>
- (IBAction)viewSegments:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *mainContentView;
@property (weak, nonatomic) IBOutlet UITableView *eventTable;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (weak, nonatomic) IBOutlet UISegmentedControl *viewSegmentControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
- (IBAction)shareClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *numMutualFriends;

@property (weak, nonatomic) IBOutlet UIView *profileButton;
@property (weak, nonatomic) IBOutlet UIView *messageButton;

@property (weak, nonatomic) IBOutlet UIView *photosButton;
@property (weak, nonatomic) IBOutlet UIView *friendsButton;



@property (weak, nonatomic) IBOutlet UIView *eventsView;
@property (weak, nonatomic) IBOutlet UIView *photosView;
@property (weak, nonatomic) IBOutlet UIView *suggestedFriendView;


@property (nonatomic, strong) NSString *targetUid;

@end
