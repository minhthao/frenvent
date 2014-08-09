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

@interface NotificationsTableViewController ()

@property (nonatomic, strong) NotificationManager *notificationManager;
@property (nonatomic, strong) NSURL *userImageUrl;

@end

@implementation NotificationsTableViewController
#pragma mark - instantiations
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

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:true];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
    [content.layer setMasksToBounds:NO];
    [content.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [content.layer setShadowRadius:3.5f];
    [content.layer setShadowOffset:CGSizeMake(1, 1)];
    [content.layer setShadowOpacity:0.5];
    for (UIView *subview in [content subviews]) {
        [subview removeFromSuperview];
    }
    
    CGRect scrollViewFrame = CGRectMake(0, 0, content.frame.size.width, content.frame.size.height);


    if ([[self notificationManager] isUserSection:indexPath.section]) {
        notificationTime.text = @"";
        if ([[self notificationManager].friendsGoingoutToday count] > 0 && indexPath.row == 0) {
            return [self getTodayEventGoersCell:tableView withIndexPath:indexPath];
        } else {
            PagedEventScrollView *eventScrollView = [[PagedEventScrollView alloc] initWithFrame:scrollViewFrame];
            eventScrollView.delegate = self;
            [eventScrollView setEvents:[self notificationManager].userInvitedEvents];
            [content addSubview:eventScrollView];
            
            notificationHeader.attributedText = [[self notificationManager] getDescriptionForInvitedEvents];
            [profilePic setImageWithURL:[self userImageUrl]];
        }
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



#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
