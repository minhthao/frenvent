//
//  NotificationsTableViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/12/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "NotificationsTableViewController.h"
#import "Notification.h"
#import "NotificationCoreData.h"
#import "Constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "TimeSupport.h"
#import "Event.h"
#import "Friend.h"
#import "BackwardTimeSupport.h"
#import "NotificationManager.h"
#import "NotificationGroup.h"
#import "EventParticipantView.h"
#import "FbUserInfoViewController.h"
#import "Reachability.h"
#import "ToastView.h"
#import "EventDetailViewController.h"
#import "UITableView+NXEmptyView.h"
#import "MyColor.h"
#import "AppDelegate.h"
#import "FriendCoreData.h"
#import "EventCoreData.h"
#import "EventDetailRecommendUserRequest.h"
#import "PagedUserScrollView.h"
#import "WebViewController.h"
#import "WebViewUser.h"

CLLocation *lastKnown;

@interface NotificationsTableViewController ()

@property(nonatomic, getter = shouldHideStatusBar) BOOL hideStatusBar;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIRefreshControl *uiRefreshControl;

@property (nonatomic, strong) NotificationManager *notificationManager;
@property (nonatomic, strong) NSURL *userImageUrl;

@property (nonatomic, strong) UIActionSheet *rsvpActionSheet;
@property (nonatomic, strong) EventRsvpRequest *eventRsvpRequest;
@property (nonatomic, strong) Event *eventToBeRsvp;
@property (nonatomic, strong) UIButton *rsvpButton;

@property (nonatomic, strong) UIAlertView *ratingAlert;

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) EventDetailRecommendUserRequest *recommendUserRequest;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *quoteArrays;
@property (nonatomic, strong) PagedUserScrollView *usersScrollView;

@end

@implementation NotificationsTableViewController
#pragma mark - instantiations
/**
 * Instantialte the empty view
 */
-(UIView *)emptyView {
    if (_emptyView == nil) {
        float screenHeight = [[UIScreen mainScreen] bounds].size.height;
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        _emptyView.backgroundColor = [MyColor eventCellButtonNormalBackgroundColor];
        
        UILabel *noResult = [[UILabel alloc] initWithFrame:CGRectMake(0, screenHeight/2 - 50, screenWidth, 36)];
        noResult.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
        noResult.textColor = [MyColor eventCellButtonsContainerBorderColor];
        noResult.shadowColor = [UIColor whiteColor];
        noResult.textAlignment = NSTextAlignmentCenter;
        noResult.shadowOffset = CGSizeMake(1, 1);
        noResult.text = @"No news feed";
        [_emptyView addSubview:noResult];
    }
    return _emptyView;
}

//init the notification manager
- (NotificationManager *)notificationManager {
    if (_notificationManager == nil) {
        _notificationManager = [[NotificationManager alloc] init];
        [_notificationManager initialize];
    }
    return _notificationManager;
}

//init and get the user image url
- (NSURL *)userImageUrl {
    if (_userImageUrl == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", [defaults objectForKey:FB_LOGIN_USER_ID]];
        _userImageUrl = [NSURL URLWithString:url];
    }
    return _userImageUrl;
}

//init the rsvp action sheet
- (UIActionSheet *)rsvpActionSheet {
    if (_rsvpActionSheet == nil) {
        _rsvpActionSheet =  [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Going", @"Maybe", nil];
        _rsvpActionSheet.delegate = self;
        _rsvpActionSheet.tag = -1;
    }
    return _rsvpActionSheet;
}

//Init the rsvp request
- (EventRsvpRequest *)eventRsvpRequest {
    if (_eventRsvpRequest == nil) {
        _eventRsvpRequest = [[EventRsvpRequest alloc] init];
        _eventRsvpRequest.delegate = self;
    }
    return _eventRsvpRequest;
}

//Get the alert
- (UIAlertView *)ratingAlert {
    if (_ratingAlert == nil) {
        _ratingAlert = [[UIAlertView alloc] initWithTitle:@"Rate Frenvent"
                                                  message:@"Please rate us on iTunes store!"
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Rate", nil];
    }
    return _ratingAlert;
}

//init recommend user
- (EventDetailRecommendUserRequest *)recommendUserRequest {
    if (_recommendUserRequest == nil) {
        _recommendUserRequest = [[EventDetailRecommendUserRequest alloc] init];
        _recommendUserRequest.delegate = self;
    }
    return _recommendUserRequest;
}

//init the location manager
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

//init the paged user scroll view
- (PagedUserScrollView *)usersScrollView {
    if (_usersScrollView == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGRect scrollViewFrame = CGRectMake(17, 0, screenWidth - 34, (screenWidth - 40) * (240/280.0));
        
        _usersScrollView = [[PagedUserScrollView alloc] initWithFrame:scrollViewFrame];
        _usersScrollView.delegate = self;
    }
    return _usersScrollView;
}

//init the quote array
- (NSMutableArray *)quoteArrays {
    if (_quoteArrays == nil) {
        _quoteArrays = [[NSMutableArray alloc] init];
        [_quoteArrays addObject:@"“The first step is you have to say that you like.”"];
        [_quoteArrays addObject:@"“It is impossible to win the race unless you venture to run.”"];
        [_quoteArrays addObject:@"“The first step toward meaningful relationship is awareness.”"];
        [_quoteArrays addObject:@"“Faith is taking the first step even when you don't see the whole staircase.”"];
        [_quoteArrays addObject:@"“A journey of a thousand miles begins with a single step.”"];
        [_quoteArrays addObject:@"“Trust is the first step to friendship.”"];
        [_quoteArrays addObject:@"“The vision must be followed by venture.”"];
        [_quoteArrays addObject:@"“It is not enough to stare up the steps - step up the stairs!”"];
        [_quoteArrays addObject:@"“Nothing ventured, nothing gained. And venture belongs to the adventurous.”"];
        [_quoteArrays addObject:@"“Everything starts with one step, or one brick, or one word or one day.”"];
    }
    return _quoteArrays;
}

#pragma mark - other delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
//        NSString *reviewURL = @"itms-apps://itunes.apple.com/app/id908123368";
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
    }
}

- (void)notifyEventDetailRecommendUserQueryFail {
    [self performSelector:@selector(refreshEnded) withObject:nil afterDelay:1];
}

- (void)notifyEventDetailRecommendUserCompleteWithResult:(NSArray *)suggestFriends {
    [self notificationManager].recommendUsers = suggestFriends;
    [self refreshEnded];
}

- (void)refreshEnded {
    [[self notificationManager] reset];
    [self.tableView reloadData];
    [[self uiRefreshControl] endRefreshing];
    [self.refreshButton setEnabled:true];
}

/**
 * Lazily create and obtain refresh control
 * @return UI refresh control
 */
- (UIRefreshControl *)uiRefreshControl {
    if (_uiRefreshControl == nil) {
        _uiRefreshControl = [[UIRefreshControl alloc] init];
        // Configure Refresh Control
        [_uiRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        
        // Configure View Controller
        [self setRefreshControl:_uiRefreshControl];
    }
    return _uiRefreshControl;
}

#pragma mark - refresh control methods
-(void)refresh:(id)sender {
    [self.refreshButton setEnabled:false];
    
    //we check if there is a internet connection, if no then stop refreshing and alert
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        NSArray *todayEvents = [EventCoreData getTodayEvents];
        if ([todayEvents count] > 0) {
            Event *selectedEvent = [todayEvents objectAtIndex:0];
            if (lastKnown != nil) {
                for (Event *event in todayEvents) {
                    [event computeDistanceToCurrentLocation:lastKnown];
                    if ([selectedEvent.distance doubleValue] == 0) {
                        if ([event.distance doubleValue] != 0) selectedEvent = event;
                        else if ([event.friendsInterested count] > [selectedEvent.friendsInterested count]) selectedEvent = event;
                        else if ([event.friendsInterested count] == [selectedEvent.friendsInterested count]
                                 && event.numInterested > selectedEvent.numInterested)
                            selectedEvent = event;
                    } else if ([event.distance doubleValue] != 0){
                        if ([selectedEvent.distance doubleValue] > 1.5 * [event.distance doubleValue]) selectedEvent = event;
                        else if ([event.distance doubleValue] < 1.5 * [selectedEvent.distance doubleValue]) {
                            if ([event.friendsInterested count] > [selectedEvent.friendsInterested count]) selectedEvent = event;
                            else if ([event.friendsInterested count] == [selectedEvent.friendsInterested count]
                                     && event.numInterested > selectedEvent.numInterested)
                                selectedEvent = event;
                        }

                    }
                }
            } else {
                for (Event *event in todayEvents) {
                    if ([event.friendsInterested count] > [selectedEvent.friendsInterested count]) selectedEvent = event;
                    else if ([event.friendsInterested count] == [selectedEvent.friendsInterested count]
                             && event.numInterested > selectedEvent.numInterested)
                        selectedEvent = event;
                }
            }
            [[self recommendUserRequest] queryRecommendUser:selectedEvent.eid];
            self.event = selectedEvent;
        } else [self performSelector:@selector(refreshEnded) withObject:nil afterDelay:1];
    } else [self performSelector:@selector(refreshEnded) withObject:nil afterDelay:1];
}


- (IBAction)doRefresh:(id)sender {
    [[self uiRefreshControl] beginRefreshing];
    [self refresh:[self uiRefreshControl]];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - [self uiRefreshControl].frame.size.height) animated:YES];
}

#pragma mark - location manager delegates
//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[self locationManager] stopUpdatingLocation];
    if (locations != nil && [locations count] > 0) {
        lastKnown = [locations objectAtIndex:0];
    }
    [self doRefresh:nil];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[self locationManager] stopUpdatingLocation];
    [self doRefresh:nil];
}



#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.tableView.nxEV_emptyView = [self emptyView];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.refreshControl = [self uiRefreshControl];
    [_uiRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        [[self locationManager] startUpdatingLocation];
    else [self doRefresh:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", (int)[UIApplication sharedApplication].applicationIconBadgeNumber];
        [self doRefresh:nil];
    } else [[self navigationController] tabBarItem].badgeValue = nil;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if ([self.navigationController respondsToSelector:@selector(hidesBarsOnSwipe)]) {
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self notificationManager] getNumberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self notificationManager] numberOfRowInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self notificationManager] getSectionTitle:section];
}

// Customize the title
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 8, 300, 18);
    myLabel.font = [UIFont fontWithName:@"SourceSansPro-SemiBold" size:14];
    myLabel.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    UIView *labelContainer = [[UIView alloc] init];
    labelContainer.frame = CGRectMake(0, 0, screenWidth, 35);
    labelContainer.backgroundColor = [UIColor whiteColor];
    [labelContainer addSubview:myLabel];
    
    UIView *topBorber = [[UIView alloc] init];
    topBorber.frame = CGRectMake(0, 0, screenWidth, 1);
    topBorber.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    
    UIView *bottomBorder = [[UIView alloc] init];
    bottomBorder.frame = CGRectMake(0, 35, screenWidth, 1);
    bottomBorder.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:labelContainer];
    if (section != 0) [headerView addSubview:topBorber];
    [headerView addSubview:bottomBorder];
    
    return headerView;
}

// Customize the height for the title
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[self notificationManager] isRecommendUsersSection:section]) return 39;
    return 48;
}

// table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self notificationManager] isRecommendUsersSection:indexPath.section]) {
        return [self getRecommendUsersCell:tableView withIndexPath:indexPath];
    } else if ([[self notificationManager] isUserSection:indexPath.section] &&
        [[self notificationManager].friendsGoingoutToday count] > 0 && indexPath.row == 0) {
            return [self getTodayEventGoersCell:tableView withIndexPath:indexPath];
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationItem" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationItem"];
        
        UIView *containerView = (UIView *)[cell viewWithTag:200];
        [containerView.layer setCornerRadius:4.0f];
        [containerView.layer setMasksToBounds:NO];
        [containerView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [containerView.layer setShadowRadius:2.5];
        [containerView.layer setShadowOffset:CGSizeMake(0, 2)];
        [containerView.layer setShadowOpacity:0.15f];
        
        UIView *profilePicContainer = (UIView *)[cell viewWithTag:201];
        CGRect profilePicFrame = CGRectMake(0, 0, profilePicContainer.frame.size.width, profilePicContainer.frame.size.height);
        UILabel *notificationHeader = (UILabel *)[cell viewWithTag:202];
        UILabel *notificationTime = (UILabel *)[cell viewWithTag:203];
        UIButton *arrowButton = (UIButton *)[cell viewWithTag:198];
        
        UIView *content = (UIView *)[cell viewWithTag:204];
        [content setBackgroundColor:[UIColor clearColor]];
        
        for (UIView *subview in [content subviews]) {
            [subview removeFromSuperview];
        }
        
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat notificationHeaderWidth = screenWidth - 125;
        [notificationHeader setPreferredMaxLayoutWidth:notificationHeaderWidth];
        
        CGRect scrollViewFrame = CGRectMake(17, 0, screenWidth - 34, content.frame.size.height);

        if ([[self notificationManager] isUserSection:indexPath.section]) {
            notificationTime.text = @"";
            PagedEventScrollView *eventScrollView = [[PagedEventScrollView alloc] initWithFrame:scrollViewFrame];
            eventScrollView.delegate = self;
            [eventScrollView setEvents:[self notificationManager].userInvitedEvents];
            [content addSubview:eventScrollView];
            
            notificationHeader.attributedText = [[self notificationManager] getDescriptionForInvitedEvents];
            UIImageView *profilePic = [[UIImageView alloc] initWithFrame:profilePicFrame];
            [profilePic setImageWithURL:[self userImageUrl]];
            [profilePicContainer addSubview:profilePic];
            
            profilePicContainer.userInteractionEnabled = YES;
            UITapGestureRecognizer *userProfileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileTap:)];
            [profilePicContainer addGestureRecognizer:userProfileTap];
            
            
            arrowButton.hidden = true;
        } else if ([[self notificationManager] isFriendActivitySection:indexPath.section]) {
            NotificationGroup *notificationGroup = [[self notificationManager].friendActivities objectAtIndex:indexPath.row];
            notificationTime.text = [BackwardTimeSupport getTimeGapName:notificationGroup.time];
            PagedEventScrollView *eventScrollView = [[PagedEventScrollView alloc] initWithFrame:scrollViewFrame];
            eventScrollView.delegate = self;
            [eventScrollView setEvents:notificationGroup.events];
            [content addSubview:eventScrollView];
            
            notificationHeader.attributedText = [[self notificationManager] getDescriptionForNotificationGroup:notificationGroup];
            EventParticipantView *participantView = [[EventParticipantView alloc] initWithFrame:profilePicFrame];
            participantView.delegate = self;
            [participantView setEventPartipant:notificationGroup.friend];
            [profilePicContainer addSubview:participantView];
            
            arrowButton.hidden = false;
            [arrowButton setUserInteractionEnabled:YES];
            [arrowButton addTarget:self action:@selector(cardArrowClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    }
}

//view cell height
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self notificationManager] isRecommendUsersSection:indexPath.section]) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        return 20 + 10 + 18 + 10 + (screenWidth - 40) * (240/280.0) + 57; //in case 320 width: this will be 363 pix
    }
    if ([[self notificationManager] isUserSection:indexPath.section]) {
        if ([[self notificationManager].friendsGoingoutToday count] > 0 && indexPath.row == 0)
            return 120;
    }
    return 260;
}

#pragma mark - table view cells
//people recommend table view cell
-(UITableViewCell *)getRecommendUsersCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationRecommendUsers" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationRecommendUsers"];
    
    UIView *containerView = (UIView *)[cell viewWithTag:1];
    [containerView.layer setCornerRadius:4.0f];
    [containerView.layer setMasksToBounds:NO];
    [containerView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [containerView.layer setShadowRadius:2.5];
    [containerView.layer setShadowOffset:CGSizeMake(0, 2)];
    [containerView.layer setShadowOpacity:0.15f];
    
    UILabel *eventNameLabel = (UILabel *)[cell viewWithTag:2];
    eventNameLabel.userInteractionEnabled = YES;
    eventNameLabel.attributedText = [self.event getFromEventNameAttributedString];
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventNameTap:)];
    [eventNameLabel addGestureRecognizer:nameTap];

    UIView *scrollView = (UIView *)[cell viewWithTag:3];
    for (UIView *subview in [[self usersScrollView] subviews]) {
        [subview removeFromSuperview];
    }
    
    [[self usersScrollView] setSuggestedUsers:[self notificationManager].recommendUsers];
    [scrollView addSubview:[self usersScrollView]];
    
    UILabel *quoteLabel = (UILabel *)[cell viewWithTag:4];
    quoteLabel.text = [self pickupQuote];
    return cell;

}

//Today event attendee table view cell
-(UITableViewCell *)getTodayEventGoersCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationTodayEventGoersItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationTodayEventGoersItem"];
    
    NSArray *friends = [self notificationManager].friendsGoingoutToday;
    
    UIView *containerView = (UIView *)[cell viewWithTag:300];
    [containerView.layer setCornerRadius:4.0f];
    [containerView.layer setMasksToBounds:NO];
    [containerView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [containerView.layer setShadowRadius:2.5];
    [containerView.layer setShadowOffset:CGSizeMake(0, 2)];
    [containerView.layer setShadowOpacity:0.15f];
    
    UILabel *notificationHeader = (UILabel *)[cell viewWithTag:301];
    notificationHeader.attributedText = [[self notificationManager] getDescriptionForFriendsGoingoutToday];
    
    UIScrollView *friendsScrollView = (UIScrollView *)[cell viewWithTag:302];
    for (UIView *subview in [friendsScrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    CGFloat friendViewSize = friendsScrollView.frame.size.height;
    [friendsScrollView setContentSize:CGSizeMake((friendViewSize + 5) * [friends count] - 5, friendViewSize)];
    
    for (int i = 0; i < [friends count]; i++) {
        CGRect friendFrame = CGRectMake((friendViewSize + 5) * i, 0, friendViewSize, friendViewSize);
        EventParticipantView *participantView = [[EventParticipantView alloc] initWithFrame:friendFrame];
        participantView.delegate = self;
        [participantView setEventPartipant:[friends objectAtIndex:i]];
        [friendsScrollView addSubview:participantView];
    }
    
    return cell;
}

#pragma mark - handle delegate for clicks
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

-(void)eventRsvpButtonClicked:(Event *)event withButton:(UIButton *)rsvpButton {
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

-(void)participantClick:(NSString *)uid {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        [self performSegueWithIdentifier:@"friendInfoView" sender:uid];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

/**
 * Handle the case when any of the suggested friends is clicked
 * @param suggest friend
 */
-(void)userClicked:(SuggestFriend *)suggestedUser {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        WebViewUser *webViewUser = [[WebViewUser alloc] init];
        webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", suggestedUser.uid];
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

/**
 * Handle the case when the say hi button is clicked
 * @param suggest friend
 */
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

/**
 * Delegate for when the suggested friends scroll view scroll from one view to another
 * @param scroll view
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == [self usersScrollView]) {
        NSIndexPath *recommendUsersIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:recommendUsersIndexPath];
        UILabel *quoteLabel = (UILabel *)[cell viewWithTag:4];
        
        [UIView transitionWithView:quoteLabel duration:.5f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
            quoteLabel.text = [self pickupQuote];
        } completion:nil];
    }
}

/**
 * A simple function that will returned a random pick up quote
 * @return NSString
 */
-(NSString *)pickupQuote {
    return (NSString *)[[self quoteArrays] objectAtIndex:(rand() % [[self quoteArrays] count])];
}

/**
 * Delegate for action sheet buttons
 */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (actionSheet.tag == -1) {
                if (self.eventToBeRsvp != nil && self.rsvpButton != nil)
                    [[self eventRsvpRequest] replyAttendingToEvent:self.eventToBeRsvp.eid];
            } else {
                NotificationGroup *notificationGroup = [[self notificationManager].friendActivities objectAtIndex:actionSheet.tag];
                Friend *friend = notificationGroup.friend;
                [FriendCoreData setFriend:friend toFavorite:false];
                [[self notificationManager] reset];
                [self.tableView reloadData];
            }
            break;
        case 1:
            if (actionSheet.tag == -1 && self.eventToBeRsvp != nil && self.rsvpButton != nil) {
                [[self eventRsvpRequest] replyUnsureToEvent:self.eventToBeRsvp.eid];
            }
            break;
        default:
            break;
    }
}

/**
 * Delegate for when when the rsvp for any event is successful
 **/
-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvp{
    if (success) {
        [self.rsvpButton setEnabled:false];
        [ToastView showToastInParentView:self.view withText:@"Event successfully RSVP!" withDuaration:3.0];
    } else [ToastView showToastInParentView:self.view withText:@"Fail to RSVP event" withDuaration:3.0];
}

#pragma mark - Navigation
/**
 * Handle event name tap
 */
-(void)eventNameTap:(UIGestureRecognizer *)recognizer {
    [self eventClicked:self.event];
}

/**
 * Handle user profile tap event
 */
-(void)userProfileTap:(UIGestureRecognizer *)recognizer {
    self.tabBarController.selectedIndex = 4;
}

/**
 * Handle click action for typical friends activities arrow. Basically allow the option to unfollow a certain user
 */
-(void)cardArrowClick:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)[[[sender superview] superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NotificationGroup *notificationGroup = [[self notificationManager].friendActivities objectAtIndex:indexPath.row];
    Friend *friend = notificationGroup.friend;
    UIActionSheet *unfollowActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Unfollow %@", friend.name], nil];
    unfollowActionSheet.tag = indexPath.row;
    [unfollowActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([[segue identifier] isEqualToString:@"webView"]) {
        WebViewController *viewController = segue.destinationViewController;
        WebViewUser *webViewUser = (WebViewUser *)sender;
        viewController.url = webViewUser.url;
        viewController.uid = webViewUser.uid;
        viewController.name = webViewUser.name;
    } else if ([[segue identifier] isEqualToString:@"friendInfoView"]) {
        NSString *uid = (NSString *)sender;
        FbUserInfoViewController *viewController = segue.destinationViewController;
        viewController.targetUid = uid;
    } else if ([[segue identifier] isEqualToString:@"eventDetailView"]) {
        NSString *eid = (NSString *)sender;
        EventDetailViewController *viewController = segue.destinationViewController;
        viewController.eid = eid;
    } 
}

- (IBAction)rateAction:(id)sender {
    [[self ratingAlert] show];
}

@end
