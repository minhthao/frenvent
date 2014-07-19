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
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "TimeSupport.h"
#import "Event.h"
#import "Friend.h"
#import "BackwardTimeSupport.h"

@interface NotificationsTableViewController ()

@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) NSURL *userImageUrl;

@end

@implementation NotificationsTableViewController
#pragma mark - instantiations
- (NSArray *)notifications {
    if (_notifications == nil) _notifications = [NotificationCoreData getNotifications:nil];
    return _notifications;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self notifications] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    Notification *notification = [[self notifications] objectAtIndex:indexPath.row];
    
    UIImageView *notificationPicture = (UIImageView *)[cell viewWithTag:600];
    UILabel *notificationMessage = (UILabel *)[cell viewWithTag:601];
    UILabel *notificationTime = (UILabel *)[cell viewWithTag:607];
    
    if ([notification.type integerValue] == TYPE_NEW_INVITE) {
        [notificationPicture setImageWithURL:[self userImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
        notificationMessage.text = @"You got invited to the event";
    } else {
        NSOrderedSet *friends = notification.friends;
        if ([friends count] > 0) {
            NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", ((Friend*)[friends objectAtIndex:0]).uid];

            [notificationPicture setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
            
            notificationMessage.attributedText = [notification getFriendsRepliedInterestedAttributedString];
        }
    }
    
    notificationTime.text = [BackwardTimeSupport getTimeGapName:[notification.time longLongValue]];
    
    UIView *notificationExtraContainer = (UIView *)[cell viewWithTag:602];
    [notificationExtraContainer.layer setCornerRadius:3.0f];
    [notificationExtraContainer.layer setMasksToBounds:YES];
    [notificationExtraContainer.layer setBorderWidth:0.5f];
    [notificationExtraContainer.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:603];
    UILabel *eventName = (UILabel *)[cell viewWithTag:604];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:605];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:606];
    
    Event *event = notification.event;
    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    
    return cell;
}




#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
