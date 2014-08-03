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
#import "TimeSupport.h"
#import "EventDetailViewController.h"
#import "PagedPhotoScrollView.h"
#import "PagedEventScrollView.h"
#import "PagedUserScrollView.h"
#import "FbUserPhotoViewController.h"
#import "FbUserInfoButtons.h"
#import "WebViewUser.h"
#import "ToastView.h"
#import "EventRsvpRequest.h"
#import "DbFBUserRequest.h"
#import "RecommendFbUserRequest.h"

@interface FbUserInfoViewController ()

@property (nonatomic, strong) FbUserInfoRequest *fbUserInfoRequest;
@property (nonatomic, strong) EventRsvpRequest *eventRsvpRequest;
@property (nonatomic, strong) RecommendFbUserRequest *recommendFbUserRequest;
@property (nonatomic, strong) NSArray *ongoingEvents;
@property (nonatomic, strong) NSArray *pastEvents;
@property (nonatomic, strong) NSArray *photoUrls;

@property (nonatomic, strong) PagedEventScrollView *eventScrollView;
@property (nonatomic, strong) PagedPhotoScrollView *photoScrollView;
@property (nonatomic, strong) PagedUserScrollView *userScrollView;
@property (nonatomic, strong) FbUserInfoButtons *userInfoButtons;

@end

@implementation FbUserInfoViewController
#pragma mark - initiation and private methods
- (FbUserInfoRequest *)fbUserInfoRequest {
    if (_fbUserInfoRequest == nil) {
        _fbUserInfoRequest = [[FbUserInfoRequest alloc] init];
        _fbUserInfoRequest.delegate = self;
    }
    return _fbUserInfoRequest;
}

- (EventRsvpRequest *)eventRsvpRequest {
    if (_eventRsvpRequest == nil) {
        _eventRsvpRequest = [[EventRsvpRequest alloc] init];
        _eventRsvpRequest.delegate = self;
    }
    return _eventRsvpRequest;
}

- (RecommendFbUserRequest *)recommendFbUserRequest {
    if (_recommendFbUserRequest == nil) {
        _recommendFbUserRequest = [[RecommendFbUserRequest alloc] init];
        _recommendFbUserRequest.delegate = self;
    }
    return _recommendFbUserRequest;
}

- (PagedEventScrollView *)eventScrollView {
    if (_eventScrollView == nil) {
        _eventScrollView =  [[PagedEventScrollView alloc] initWithFrame:CGRectMake(0, 40, 320, 180)];
        _eventScrollView.delegate = self;
        [self maskPagedScrollView:_eventScrollView];
    }
    return _eventScrollView;
}

- (PagedPhotoScrollView *)photoScrollView {
    if (_photoScrollView == nil) {
        _photoScrollView = [[PagedPhotoScrollView alloc] initWithFrame:CGRectMake(0, 40, 320, 200)];
        _photoScrollView.delegate = self;
        [self maskPagedScrollView:_photoScrollView];
    }
    return _photoScrollView;
}

- (PagedUserScrollView *)userScrollView {
    if (_userScrollView == nil) {
        _userScrollView = [[PagedUserScrollView alloc] initWithFrame:CGRectMake(0, 40, 320, 150)];
        _userScrollView.delegate = self;
        [self maskPagedScrollView:_userScrollView];
    }
    return _userScrollView;
}

- (FbUserInfoButtons *)userInfoButtons {
    if (_userInfoButtons == nil) {
        _userInfoButtons = [[FbUserInfoButtons alloc] initWithFrame:CGRectMake(10, 5, 300, 64)];
        _userInfoButtons.delegate = self;
    }
    return _userInfoButtons;
}

- (void)maskPagedScrollView:(UIView *)view {
    [view.layer setMasksToBounds:NO];
    [view.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [view.layer setShadowRadius:3.5f];
    [view.layer setShadowOffset:CGSizeMake(1, 1)];
    [view.layer setShadowOpacity:0.5];

}

#pragma mark - alert view delegate
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
     [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - paged scroll view delegate
-(void)imageIndexClicked:(int)index {
    [self performSegueWithIdentifier:@"photoView" sender:[NSNumber numberWithInt:index]];
}

-(void)eventClicked:(Event *)event {
    [self performSegueWithIdentifier:@"eventDetailView" sender:event.eid];
}

-(void)eventRsvpButtonClicked:(Event *)event {
    [[self eventRsvpRequest] replyAttendingToEvent:event.eid];
}

-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvpb{
    if (success) [ToastView showToastInParentView:self.view withText:@"Event successfully RSVP!" withDuaration:3.0];
    else [ToastView showToastInParentView:self.view withText:@"Fail to RSVP event" withDuaration:3.0];
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

#pragma mark - button tap
- (void)profileButtonTap {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", self.targetUid];
    webViewUser.uid = self.targetUid;
    webViewUser.name = self.username.text;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

- (void)messageButtonTap {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/messages/compose?ids=%@", self.targetUid];
    webViewUser.uid = self.targetUid;
    webViewUser.name = self.username.text;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

- (void)photoButtonTap {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?v=photos&id=%@", self.targetUid];
    webViewUser.uid = self.targetUid;
    webViewUser.name = self.username.text;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

- (void)friendButtonTap {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?v=friends&id=%@", self.targetUid];
    webViewUser.uid = self.targetUid;
    webViewUser.name = self.username.text;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

#pragma mark - Fb user info request delegate
-(void) notifyFbUserInfoRequestFail {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"User did not exist or you don't have permission to access this user."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

-(void) fbUserInfoRequestMutualFriendsCount:(int16_t)mutualFriendsCount {
    self.numMutualFriends.text = [NSString stringWithFormat:@"%d mutual friends", mutualFriendsCount];
}

-(void) fbUserInfoRequestName:(NSString *)name {
    self.username.text = name;
    if ([DbFBUserRequest addFbUserWithUid:self.targetUid andName:name])
        [self.shareButton setEnabled:[FBDialogs canPresentMessageDialog]];
}

-(void) fbUserInfoRequestOngoingEvents:(NSArray *)ongoingEvents {
    self.ongoingEvents = ongoingEvents;
    if ([self.ongoingEvents count] > 0) {
        [self.eventTable reloadData];
    }
    [[self eventScrollView] setEvents:ongoingEvents];
    [self.mainTable reloadData];
}

-(void) fbUserInfoRequestSuggestedFriends:(NSArray *)users {
    [[self userScrollView] setSuggestedUsers:users];
    [self.mainTable reloadData];
}

-(void) fbUserInfoRequestPhotos:(NSArray *)urls {
    self.photoUrls = urls;
    [[self photoScrollView] setScrollViewPhotoUrls:urls withContentModeFit:NO];
    [self.mainTable reloadData];
}

-(void) fbUserInfoRequestPastEvents:(NSArray *)pastEvents {
    self.pastEvents = pastEvents;
    if ([self.pastEvents count] > 0) [self.eventTable reloadData];
}

-(void) fbUserInfoRequestProfileCover:(NSString *)cover {
    //we first setup the view
    [self.mainTable setHidden:false];
    [self.loadingSpinner stopAnimating];
    [self.viewSegmentControl setEnabled:true];
    [self.viewSegmentControl setSelectedSegmentIndex:0];
    [self.shareButton setEnabled:true];
    
    if ([cover length] > 0)
        [self.coverImage setImageWithURL:[NSURL URLWithString:cover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    else [self.coverImage setImage:[MyColor imageWithColor:[UIColor darkGrayColor]]];   
    
}

#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mainTable setHidden:true];
    [self.eventTable setHidden:true];
    [self.loadingSpinner setHidesWhenStopped:true];
    [self.loadingSpinner startAnimating];
    [self.shareButton setEnabled:false];
    [self.viewSegmentControl setEnabled:false];
    
    FbUserInfoButtons *infoButtons = [[FbUserInfoButtons alloc] initWithFrame:CGRectMake(10, 154, 300, 64)];
    infoButtons.delegate = self;

    //view load
    if (self.targetUid != nil) {
        NSString *profilePictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", self.targetUid];
        [self.profileImage setImageWithURL:[NSURL URLWithString:profilePictureUrl]];
        [[self fbUserInfoRequest] queryFbUserInfo:self.targetUid];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Unknown Error"
                                                          message:@"Frenvent encounter unknown error, attempt to recover to prev state."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];

    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.profileImage.layer setMasksToBounds:YES];
    [self.profileImage.layer setBorderWidth:3];
    [self.profileImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view segment
- (IBAction)viewSegments:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger index = [segmentedControl selectedSegmentIndex];
    
    if (index == 0) {
        [self.mainTable setHidden:false];
        [self.eventTable setHidden:true];
    } else if (index == 1) {
        [self.mainTable setHidden:true];
        [self.eventTable setHidden:false];
    }
}

- (IBAction)shareClicked:(id)sender {
    [[self recommendFbUserRequest] shareUserWithUid:self.targetUid];
}

#pragma mark - table view delegate
// Get the number of section in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([tableView isEqual:self.mainTable]) return 2;
    else {
        NSInteger numSections = 0;
        if ([self.ongoingEvents count] > 0) numSections++;
        if ([self.pastEvents count] > 0) numSections++;
        return numSections;
    }
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.mainTable]) return nil;
    else {
        if (section == 0 && [self.ongoingEvents count] > 0) return @"FUTURE EVENTS";
        else if ((section == 0 && [self.ongoingEvents count] == 0) || section == 1) return @"PAST EVENTS";
        else return nil;
    }
}

// Get the number of row in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.mainTable]) {
        if (section == 0) return 1;
        else return 3;
    } else {
        if (section == 0 && [self.ongoingEvents count] > 0) return [self.ongoingEvents count];
        else if ((section == 0 && [self.ongoingEvents count] == 0) || section == 1) return [self.pastEvents count];
        else return 0;
    }
}

// Display the table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.eventTable]) return [self eventCellForRowAtIndexPath:indexPath];
    else return [self mainContentCellForRowAtIndexPath:indexPath];
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event;
    if (indexPath.section == 0 && [self.ongoingEvents count] > 0) event =
        [self.ongoingEvents objectAtIndex:indexPath.row];
    else if ((indexPath.section == 0 && [self.ongoingEvents count] == 0) || indexPath.section == 1)
        event = [self.pastEvents objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"eventDetailView" sender:event.eid];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.eventTable]) return 105;
    else {
        if (indexPath.section == 0) return 80;
        else {
            if (indexPath.row == 0) return 230;
            else if (indexPath.row == 1) return 250;
            else return 200;
        }
    }
}

#pragma mark - table view cell configuration
- (UITableViewCell *)eventCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.eventTable dequeueReusableCellWithIdentifier:@"fbUserEventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fbUserEventItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    Event *event;
    if (indexPath.section == 0 && [self.ongoingEvents count] > 0)
        event = [self.ongoingEvents objectAtIndex:indexPath.row];
    else if ((indexPath.section == 0 && [self.ongoingEvents count] == 0) || indexPath.section == 1)
        event = [self.pastEvents objectAtIndex:indexPath.row];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:400];
    UILabel *eventName = (UILabel *)[cell viewWithTag:401];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:402];
    UILabel *eventHost = (UILabel *)[cell viewWithTag:403];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:404];
    
    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;
    eventHost.attributedText = [event getHostAttributedString];
    
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    return cell;

}

- (UITableViewCell *)mainContentCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [self.mainTable dequeueReusableCellWithIdentifier:@"fbUserInfoMainContentButtons" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fbUserInfoMainContentButtons"];
        [cell setUserInteractionEnabled:true];
        
        UIView *contentView = (UIView *)[cell viewWithTag:1000];
        [contentView addSubview:[self userInfoButtons]];
        return cell;
    } else {
        UITableViewCell *cell = [self.mainTable dequeueReusableCellWithIdentifier:@"fbUserInfoMainContentViews" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fbUserInfoMainContentViews"];
        
        UIView *cellContainer = (UIView *)[cell viewWithTag:1100];
        UILabel *cellTitleLabel = (UILabel *)[cell viewWithTag:1101];
        
        if (indexPath.row == 0) {
            cellTitleLabel.text = @"Upcoming Events";
            [cellContainer addSubview:[self eventScrollView]];
        } else if (indexPath.row == 1) {
            cellTitleLabel.text = @"Photos";
            [cellContainer addSubview:[self photoScrollView]];
        } else if (indexPath.row == 2) {
            cellTitleLabel.text = @"Suggested Friends";
            [cellContainer addSubview:[self userScrollView]];
        }
        
        return cell;
    }
}

#pragma mark - segue preparation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToSelf"]) {
        NSString *uid = (NSString *)sender;
        FbUserInfoViewController *viewController = segue.destinationViewController;
        viewController.targetUid = uid;
    } else if ([[segue identifier] isEqualToString:@"webView"]) {
        WebViewController *viewController = segue.destinationViewController;
        WebViewUser *webViewUser = (WebViewUser *)sender;
        viewController.url = webViewUser.url;
        viewController.uid = webViewUser.uid;
        viewController.name = webViewUser.name;
    } else if ([[segue identifier] isEqualToString:@"eventDetailView"]) {
        NSString *eid = (NSString *)sender;
        EventDetailViewController *viewController = segue.destinationViewController;
        viewController.eid = eid;
    } else if ([[segue identifier] isEqualToString:@"photoView"]) {
        int photoIndex = [(NSNumber *)sender intValue];
        FbUserPhotoViewController *viewController = segue.destinationViewController;
        viewController.photoUrls = self.photoUrls;
        viewController.index = photoIndex;
    }
}

@end
