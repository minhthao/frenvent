//
//  FirstLoadingViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendEventsRequest.h"
#import "MyEventsRequest.h"
#import "FriendsRequest.h"
#import "DbEventsRequest.h"
#import "DBNotificationRequest.h"
@interface FirstLoadingViewController : UIViewController <CLLocationManagerDelegate, FriendEventsRequestDelegate, MyEventsRequestDelegate, FriendsRequestDelegate, DbEventsRequestDelegate, DBNotificationRequestDelegate, UIScrollViewDelegate,  UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *tutorialView;
@property (weak, nonatomic) IBOutlet UIScrollView *tutorialScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIView *friendSelectionView;
@property (weak, nonatomic) IBOutlet UITableView *selectionFriendTable;
- (IBAction)nextActionFromSelectionView:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *secondLoginView;
@property (weak, nonatomic) IBOutlet UIWebView *secondLoginWebView;
- (IBAction)doneAction:(id)sender;

@end
