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
#import "EventParticipant.h"
#import "EventParticipantView.h"
#import "FbUserInfoViewController.h"
#import "Reachability.h"
#import "ToastView.h"
#import "EventDetailViewController.h"
#import "UITableView+NXEmptyView.h"
#import "MyColor.h"

@interface NotificationsTableViewController ()

@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic, strong) NotificationManager *notificationManager;
@property (nonatomic, strong) NSURL *userImageUrl;

@property (nonatomic, strong) UIActionSheet *rsvpActionSheet;
@property (nonatomic, strong) EventRsvpRequest *eventRsvpRequest;
@property (nonatomic, strong) Event *eventToBeRsvp;
@property (nonatomic, strong) UIButton *rsvpButton;

@end

@implementation NotificationsTableViewController
#pragma mark - instantiations
-(UIView *)emptyView {
    if (_emptyView == nil) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        _emptyView.backgroundColor = [MyColor eventCellButtonNormalBackgroundColor];
        
        UILabel *noResult = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height/2 - 50, self.tableView.frame.size.width, 36)];
        noResult.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
        noResult.textColor = [MyColor eventCellButtonsContainerBorderColor];
        noResult.shadowColor = [UIColor whiteColor];
        noResult.textAlignment = NSTextAlignmentCenter;
        noResult.shadowOffset = CGSizeMake(1, 1);
        noResult.text = @"No new feeds";
        [_emptyView addSubview:noResult];
    }
    return _emptyView;
}

- (NotificationManager *)notificationManager {
    if (_notificationManager == nil) {
        _notificationManager = [[NotificationManager alloc] init];
        [_notificationManager initialize];
    }
    return _notificationManager;
}

- (NSURL *)userImageUrl {
    if (_userImageUrl == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", [defaults objectForKey:FB_LOGIN_USER_ID]];
        _userImageUrl = [NSURL URLWithString:url];
    }
    return _userImageUrl;
}

- (UIActionSheet *)rsvpActionSheet {
    if (_rsvpActionSheet == nil) {
        _rsvpActionSheet =  [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Going", @"Maybe", nil];
        _rsvpActionSheet.delegate = self;
    }
    return _rsvpActionSheet;
}

- (EventRsvpRequest *)eventRsvpRequest {
    if (_eventRsvpRequest == nil) {
        _eventRsvpRequest = [[EventRsvpRequest alloc] init];
        _eventRsvpRequest.delegate = self;
    }
    return _eventRsvpRequest;
}


#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.tableView.nxEV_emptyView = [self emptyView];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController setNavigationBarHidden:NO animated:true];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if ([self notificationManager] != nil) {
        [[self notificationManager] reset];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self notificationManager] isUserSection:indexPath.section] &&
        [[self notificationManager].friendsGoingoutToday count] > 0 && indexPath.row == 0) {
            return [self getTodayEventGoersCell:tableView withIndexPath:indexPath];
        
    } else {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationItem" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationItem"];
        
        UIView *containerView = (UIView *)[cell viewWithTag:200];
        [containerView.layer setCornerRadius:3.0f];
        [containerView.layer setMasksToBounds:YES];
        [containerView.layer setBorderWidth:0.5f];
        [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        
        UIImageView *profilePic = (UIImageView *)[cell viewWithTag:201];
        UILabel *notificationHeader = (UILabel *)[cell viewWithTag:202];
        UILabel *notificationTime = (UILabel *)[cell viewWithTag:203];
        
        UIView *content = (UIView *)[cell viewWithTag:204];
        [content setBackgroundColor:[UIColor clearColor]];
        
        for (UIView *subview in [content subviews]) {
            [subview removeFromSuperview];
        }
        
        CGRect scrollViewFrame = CGRectMake(12, 0, content.frame.size.width - 24, content.frame.size.height);


        if ([[self notificationManager] isUserSection:indexPath.section]) {
            notificationTime.text = @"";
            PagedEventScrollView *eventScrollView = [[PagedEventScrollView alloc] initWithFrame:scrollViewFrame];
            eventScrollView.delegate = self;
            [eventScrollView setEvents:[self notificationManager].userInvitedEvents];
            [content addSubview:eventScrollView];
            
            notificationHeader.attributedText = [[self notificationManager] getDescriptionForInvitedEvents];
            [profilePic setImageWithURL:[self userImageUrl]];
        } else if ([[self notificationManager] isTodaySection:indexPath.section]) {
            NotificationGroup *notificationGroup = [[self notificationManager].todayNotification objectAtIndex:indexPath.row];
            notificationTime.text = [BackwardTimeSupport getTimeGapName:notificationGroup.time];
            PagedEventScrollView *eventScrollView = [[PagedEventScrollView alloc] initWithFrame:scrollViewFrame];
            eventScrollView.delegate = self;
            [eventScrollView setEvents:notificationGroup.events];
            [content addSubview:eventScrollView];
            
            notificationHeader.attributedText = [[self notificationManager] getDescriptionForNotificationGroup:notificationGroup];
            NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", notificationGroup.friend.uid];
            [profilePic setImageWithURL:[NSURL URLWithString:url]];
        } else if ([[self notificationManager] isThisWeekSection:indexPath.section]) {
            NotificationGroup *notificationGroup = [[self notificationManager].thisWeekNotification objectAtIndex:indexPath.row];
            notificationTime.text = [BackwardTimeSupport getTimeGapName:notificationGroup.time];
            PagedEventScrollView *eventScrollView = [[PagedEventScrollView alloc] initWithFrame:scrollViewFrame];
            eventScrollView.delegate = self;
            [eventScrollView setEvents:notificationGroup.events];
            [content addSubview:eventScrollView];
            
            notificationHeader.attributedText = [[self notificationManager] getDescriptionForNotificationGroup:notificationGroup];
            NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", notificationGroup.friend.uid];
            [profilePic setImageWithURL:[NSURL URLWithString:url]];
        } else if ([[self notificationManager] isOthersSection:indexPath.section]) {
            Notification *notification = [[self notificationManager].othersNotification objectAtIndex:indexPath.row];
            notificationTime.text = [BackwardTimeSupport getTimeGapName:[notification.time longLongValue]];
            PagedEventScrollView *eventScrollView = [[PagedEventScrollView alloc] initWithFrame:scrollViewFrame];
            eventScrollView.delegate = self;
            [eventScrollView setEvents:@[notification.event]];
            [content addSubview:eventScrollView];
            
            notificationHeader.attributedText = [[self notificationManager] getDescriptionForNotification:notification];
            NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", notification.friend.uid];
            [profilePic setImageWithURL:[NSURL URLWithString:url]];
        }
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self notificationManager] isUserSection:indexPath.section]) {
        if ([[self notificationManager].friendsGoingoutToday count] > 0 && indexPath.row == 0)
            return 120;
    }
    return 249;
}

-(UITableViewCell *)getTodayEventGoersCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationTodayEventGoersItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationTodayEventGoersItem"];
    
    NSArray *friends = [self notificationManager].friendsGoingoutToday;
    
    UIView *containerView = (UIView *)[cell viewWithTag:300];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
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

-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvpb{
    if (success) {
        [self.rsvpButton setEnabled:false];
        [ToastView showToastInParentView:self.view withText:@"Event successfully RSVP!" withDuaration:3.0];
    } else [ToastView showToastInParentView:self.view withText:@"Fail to RSVP event" withDuaration:3.0];
}




#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"friendInfoView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        NSString *uid = (NSString *)sender;
        FbUserInfoViewController *viewController = segue.destinationViewController;
        viewController.targetUid = uid;
    } else if ([[segue identifier] isEqualToString:@"eventDetailView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        NSString *eid = (NSString *)sender;
        EventDetailViewController *viewController = segue.destinationViewController;
        viewController.eid = eid;
    }
}


@end
