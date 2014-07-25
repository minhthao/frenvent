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

@interface FbUserInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FbUserInfoRequestDelegate, UIAlertViewDelegate>
- (IBAction)viewSegments:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *userInfoTable;
@property (weak, nonatomic) IBOutlet UITableView *mutualFriendsTable;

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *numMutualFriends;

@property (weak, nonatomic) IBOutlet UIView *profileButton;
@property (weak, nonatomic) IBOutlet UIView *messageButton;
@property (weak, nonatomic) IBOutlet UIView *photoButton;
@property (weak, nonatomic) IBOutlet UIView *eventButton;

@property (nonatomic, strong) NSString *targetUid;

@end
