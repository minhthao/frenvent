//
//  FriendInfoViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FbUserInfoViewController.h"
#import "FbUserInfoRequest.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "Friend.h"
#import "MyColor.h"
#import "WebViewController.h"
#import "Event.h"
#import "EventDetailViewController.h"
#import "PagedPhotoScrollView.h"
#import "PagedEventScrollView.h"
#import "PagedFbUserScrollView.h"
#import "FbUserPhotoViewController.h"
#import "WebViewUser.h"
#import "ToastView.h"
#import "EventRsvpRequest.h"
#import "DbFBUserRequest.h"
#import "RecommendFbUserRequest.h"
#import "Reachability.h"

@interface FbUserInfoViewController ()

@property (nonatomic, strong) UIActionSheet *rsvpActionSheet;

@property (nonatomic, strong) FbUserInfoRequest *fbUserInfoRequest;
@property (nonatomic, strong) EventRsvpRequest *eventRsvpRequest;
@property (nonatomic, strong) RecommendFbUserRequest *recommendFbUserRequest;
@property (nonatomic, strong) FbUserInfo *fbUserInfo;

@property (nonatomic, strong) PagedEventScrollView *eventScrollView;
@property (nonatomic, strong) PagedPhotoScrollView *photoScrollView;
@property (nonatomic, strong) PagedFbUserScrollView *userScrollView;

@property (nonatomic, strong) Event *eventToBeRsvp;
@property (nonatomic, strong) UIButton *rsvpButton;

@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *messageButton;

@end

@implementation FbUserInfoViewController
#pragma mark - initiation and private methodss
/**
 * Lazily instantiate the rsvp action sheet
 * @return UIActionSheet
 */
- (UIActionSheet *)rsvpActionSheet {
    if (_rsvpActionSheet == nil) {
        _rsvpActionSheet =  [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Going", @"Maybe", nil];
        _rsvpActionSheet.delegate = self;
    }
    return _rsvpActionSheet;
}

/**
 * Lazily instantiate the fb user info request
 * @return FbUserInfoRequest
 */
- (FbUserInfoRequest *)fbUserInfoRequest {
    if (_fbUserInfoRequest == nil) {
        _fbUserInfoRequest = [[FbUserInfoRequest alloc] init];
        _fbUserInfoRequest.delegate = self;
    }
    return _fbUserInfoRequest;
}

/**
 * Lazily instantiate the event rsvp request
 * @return EventRsvpRequest
 */
- (EventRsvpRequest *)eventRsvpRequest {
    if (_eventRsvpRequest == nil) {
        _eventRsvpRequest = [[EventRsvpRequest alloc] init];
        _eventRsvpRequest.delegate = self;
    }
    return _eventRsvpRequest;
}

/**
 * Lazily instantiate the recommend fb user request
 * @return RecommendFbUserRequest
 */
- (RecommendFbUserRequest *)recommendFbUserRequest {
    if (_recommendFbUserRequest == nil) {
        _recommendFbUserRequest = [[RecommendFbUserRequest alloc] init];
        _recommendFbUserRequest.delegate = self;
    }
    return _recommendFbUserRequest;
}

/**
 * Lazily instantiate the event scroll view
 * @return PagedEventScrollView
 */
- (PagedEventScrollView *)eventScrollView {
    if (_eventScrollView == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _eventScrollView =  [[PagedEventScrollView alloc] initWithFrame:CGRectMake(17, 0, screenWidth - 34, 170)];
        _eventScrollView.delegate = self;
    }
    return _eventScrollView;
}

/**
 * Lazily instantiate the photo scroll view
 * @return PagedPhotoScrollView
 */
- (PagedPhotoScrollView *)photoScrollView {
    if (_photoScrollView == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _photoScrollView = [[PagedPhotoScrollView alloc] initWithFrame:CGRectMake(17 , 0, screenWidth - 34, 0.6 * screenWidth)];
        _photoScrollView.delegate = self;
    }
    return _photoScrollView;
}

/**
 * Lazily instantiate the user scroll view
 * @return PagedFbUserScrollView
 */
- (PagedFbUserScrollView *)userScrollView {
    if (_userScrollView == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _userScrollView = [[PagedFbUserScrollView alloc] initWithFrame:CGRectMake(17, 0, screenWidth - 34, 170)];
        _userScrollView.delegate = self;
    }
    return _userScrollView;
}

/**
 * Lazily instantiate the profile button
 * @return UIButton
 */
-(UIButton *)profileButton {
    if (_profileButton == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth * 0.33, 75)];
        [_profileButton setImage:[UIImage imageNamed:@"FbUserInfoProfileButton"] forState:UIControlStateNormal];
        [_profileButton addTarget:self action:@selector(profileButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _profileButton;
}

/**
 * Lazily instantiate the save button
 * @return UIButton
 */
-(UIButton *)messageButton {
    if (_messageButton == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _messageButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth * 0.335, 0, screenWidth * 0.33, 75)];
        [_messageButton setImage:[UIImage imageNamed:@"FbUserInfoMessageButton"] forState:UIControlStateNormal];
        [_messageButton addTarget:self action:@selector(messageButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageButton;
}

/**
 * Lazily instantiate the more button
 * @return UIButton
 */
-(UIButton *)photoButton {
    if (_photoButton == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _photoButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth * 0.67, 0, screenWidth * 0.33, 75)];
        [_photoButton setImage:[UIImage imageNamed:@"FbUserInfoPhotoButton"] forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(photoButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}


#pragma mark - alert view and actionsheet delegates
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
     [self.navigationController popViewControllerAnimated:true];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (self.eventToBeRsvp != nil && self.rsvpButton != nil) {
                [[self eventRsvpRequest] replyAttendingToEvent:self.eventToBeRsvp.eid];
            }
            break;
        case 1:
            if (self.eventToBeRsvp != nil && self.rsvpButton != nil) {
                [[self eventRsvpRequest] replyUnsureToEvent:self.eventToBeRsvp.eid];
            }
            break;
        default:
            break;
    }
}


#pragma mark - paged scroll view delegate
-(void)imageIndexClicked:(int)index {
    [self performSegueWithIdentifier:@"photoView" sender:[NSNumber numberWithInt:index]];
}

-(void)eventClicked:(Event *)event {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        [self performSegueWithIdentifier:@"eventDetailView" sender:event.eid];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
}

-(void)eventRsvpButtonClicked:(Event *)event withButton:(UIButton *)rsvpButton{
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        self.eventToBeRsvp = event;
        self.rsvpButton = rsvpButton;
        [[self rsvpActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
}

-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvpb{
    if (success) {
        [self.rsvpButton setEnabled:false];
        [ToastView showToastInParentView:self.view withText:@"Event successfully RSVP!" withDuaration:3.0];
    } else [ToastView showToastInParentView:self.view withText:@"Fail to RSVP event" withDuaration:3.0];
}

-(void)notifyRecommendFbUserRequestSuccess:(BOOL)success {
    if (success) [ToastView showToastInParentView:self.view withText:@"User shared successfully" withDuaration:3.0];
    else [ToastView showToastInParentView:self.view withText:@"Fail to share user" withDuaration:3.0];
}

-(void)userClicked:(SuggestFriend *)suggestedUser {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", suggestedUser.uid];
    webViewUser.uid = suggestedUser.uid;
    webViewUser.name = suggestedUser.name;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

-(void)hiButtonClicked:(SuggestFriend *)suggestedUser {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        WebViewUser *webViewUser = [[WebViewUser alloc] init];
        webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/messages/compose?ids=%@", suggestedUser.uid];
        webViewUser.uid = suggestedUser.uid;
        webViewUser.name = suggestedUser.name;
        [self performSegueWithIdentifier:@"webView" sender:webViewUser];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

#pragma mark - button tap
- (void)profileButtonTap {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", self.targetUid];
    webViewUser.uid = self.targetUid;
    webViewUser.name = self.fbUserInfo.name;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

- (void)messageButtonTap {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/messages/compose?ids=%@", self.targetUid];
    webViewUser.uid = self.targetUid;
    webViewUser.name = self.fbUserInfo.name;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

- (void)photoButtonTap {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?v=photos&id=%@", self.targetUid];
    webViewUser.uid = self.targetUid;
    webViewUser.name = self.fbUserInfo.name;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

- (IBAction)shareClicked:(id)sender {
    [[self recommendFbUserRequest] shareUserWithUid:self.targetUid];
}

#pragma mark - Fb user info request delegate
-(void)fbUserInfoRequestResult:(FbUserInfo *)userInfo {
    self.fbUserInfo = userInfo;
    [self.loadingSpinner stopAnimating];
    
    if (userInfo == nil) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"User did not exist or you don't have permission to access this user."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    } else {
        if (userInfo.recommendFriends && [userInfo.recommendFriends count] > 0)
            [[self userScrollView] setSuggestedUsers:userInfo.recommendFriends];
        if (userInfo.photos && [userInfo.photos count] > 0)
            [[self photoScrollView] setScrollViewPhotoUrls:self.fbUserInfo.photos withContentModeFit:NO];
        if (userInfo.events && [userInfo.events count] > 0)
            [[self eventScrollView] setEvents:self.fbUserInfo.events];
        
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        
        UIImageView *cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, self.headerView.frame.size.height)];
        cover.backgroundColor = [UIColor lightGrayColor];
        cover.contentMode = UIViewContentModeScaleAspectFill;
        cover.clipsToBounds = YES;
        if (userInfo.cover != nil && [userInfo.cover length] > 0) [cover setImageWithURL:[NSURL URLWithString:userInfo.cover]];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, self.headerView.frame.size.height - 40, screenWidth, 40);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.95] CGColor], nil];
        [cover.layer insertSublayer:gradient atIndex:0];
        [self.headerView addSubview:cover];

        UIImageView *profilePic = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.headerView.frame.size.height - 90, 75, 75)];
        profilePic.contentMode = UIViewContentModeScaleAspectFill;
        [profilePic.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [profilePic.layer setBorderWidth:2];
        NSString *profileUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=150&height=150", self.targetUid];
        [profilePic setImageWithURL:[NSURL URLWithString:profileUrl]];
        [self.headerView addSubview:profilePic];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(110, self.headerView.frame.size.height - 35, screenWidth - 130, 20)];
        name.font = [UIFont fontWithName:@"SourceSansPro-Semibold" size:16];
        name.textColor = [UIColor whiteColor];
        name.text = userInfo.name;
        [self.headerView addSubview:name];
        self.title = userInfo.name;
            
        [self.mainTable reloadData];
        if ([DbFBUserRequest addFbUserWithUid:self.targetUid andName:userInfo.name])
            [self.shareButton setEnabled:[FBDialogs canPresentMessageDialog]];
        
    }
}

#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.shareButton setEnabled:false];

    [[self fbUserInfoRequest] queryFbUserInfo:self.targetUid];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        self.navigationController.hidesBarsOnSwipe = YES;
        [self.navigationController.barHideOnSwipeGestureRecognizer addTarget:self action:@selector(swipe:)];
    }
    
    CGRect navFrame =  self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, navFrame.size.width, 64);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        [self.navigationController.barHideOnSwipeGestureRecognizer removeTarget:self action:@selector(swipe:)];
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2 animations:^{
        [UIApplication sharedApplication].statusBarHidden = (self.navigationController.navigationBar.frame.origin.y < 0);
        
        if (![UIApplication sharedApplication].statusBarHidden) {
            CGRect navFrame =  self.navigationController.navigationBar.frame;
            self.navigationController.navigationBar.frame = CGRectMake(0, 0, navFrame.size.width, 64);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate
//number of sections in table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.fbUserInfo == nil) return 0;
    else return 1;
}

//number of row in section. If recommended users are found, then 3. Otherwise, it will be 2
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;
    if (self.fbUserInfo.recommendFriends && [self.fbUserInfo.recommendFriends count] > 0) numRows++;
    if (self.fbUserInfo.photos && [self.fbUserInfo.photos count] > 0) numRows++;
    if (self.fbUserInfo.events && [self.fbUserInfo.events count] > 0) numRows++;

    return numRows;
}

// customized header view
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *buttonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 75)];
    buttonsContainer.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [buttonsContainer.layer setMasksToBounds:NO];
    [buttonsContainer.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [buttonsContainer.layer setShadowRadius:2];
    [buttonsContainer.layer setShadowOffset:CGSizeMake(0, 2)];
    [buttonsContainer.layer setShadowOpacity:0.15f];
    
    [buttonsContainer addSubview:[self profileButton]];
    [buttonsContainer addSubview:[self photoButton]];
    [buttonsContainer addSubview:[self messageButton]];
    
    [headerView addSubview:buttonsContainer];
    return headerView;
}

// Customize the height for the title
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

// Display the table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellView"];
    
    UIView *containerView = (UIView *)[cell viewWithTag:100];
    [containerView.layer setCornerRadius:4.0f];
    [containerView.layer setMasksToBounds:NO];
    [containerView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [containerView.layer setShadowRadius:2.5];
    [containerView.layer setShadowOffset:CGSizeMake(0, 2)];
    [containerView.layer setShadowOpacity:0.15f];
    
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    UIView *scrollViewContainer = (UIView *)[cell viewWithTag:102];
    
    for (UIView *subView in scrollViewContainer.subviews) {
        [subView removeFromSuperview];
    }
    
    NSString *shortenName = [[self.fbUserInfo.name componentsSeparatedByString:@" "] objectAtIndex:0];
    
    if (indexPath.row == 0) {
        if (self.fbUserInfo.recommendFriends && [self.fbUserInfo.recommendFriends count] > 0) {
            label.text = [NSString stringWithFormat:@"People %@'s been hanging out with", shortenName];
            [scrollViewContainer addSubview:[self userScrollView]];
        } else if (self.fbUserInfo.events && [self.fbUserInfo.events count] > 0) {
            label.text = @"Upcoming Events";
            [scrollViewContainer addSubview:[self eventScrollView]];
        } else {
            label.text = @"User Photos";
            [scrollViewContainer addSubview:[self photoScrollView]];
        }
    } else if (indexPath.row == 1) {
        if (self.fbUserInfo.recommendFriends && [self.fbUserInfo.recommendFriends count] > 0) {
            if (self.fbUserInfo.events && [self.fbUserInfo.events count] > 0) {
                label.text = @"Upcoming Events";
                [scrollViewContainer addSubview:[self eventScrollView]];
            } else {
                label.text = @"User Photos";
                [scrollViewContainer addSubview:[self photoScrollView]];
            }
        } else {
            label.text = @"User Photos";
            [scrollViewContainer addSubview:[self photoScrollView]];
        }
    } else {
        label.text = @"User Photos";
        [scrollViewContainer addSubview:[self photoScrollView]];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    if (indexPath.row == 0) {
        if (self.fbUserInfo.recommendFriends && [self.fbUserInfo.recommendFriends count] > 0) return 241;
        else if (self.fbUserInfo.events && [self.fbUserInfo.events count] > 0) return 241;
    } else if (indexPath.row == 1) {
        if (self.fbUserInfo.recommendFriends && [self.fbUserInfo.recommendFriends count] > 0) {
            if (self.fbUserInfo.events && [self.fbUserInfo.events count] > 0) return 241;
        }
    }
    return 0.6 * screenWidth + 71;
}

#pragma mark - segue preparation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"webView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        WebViewController *viewController = segue.destinationViewController;
        WebViewUser *webViewUser = (WebViewUser *)sender;
        viewController.url = webViewUser.url;
        viewController.uid = webViewUser.uid;
        viewController.name = webViewUser.name;
    } else if ([[segue identifier] isEqualToString:@"eventDetailView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        NSString *eid = (NSString *)sender;
        EventDetailViewController *viewController = segue.destinationViewController;
        viewController.eid = eid;
    } else if ([[segue identifier] isEqualToString:@"photoView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        int photoIndex = [(NSNumber *)sender intValue];
        FbUserPhotoViewController *viewController = segue.destinationViewController;
        viewController.photoUrls = self.fbUserInfo.photos;
        viewController.index = photoIndex;
    }
}

@end
