//
//  MoreTableViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "MoreTableViewController.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface MoreTableViewController ()

@end

@implementation MoreTableViewController

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [defaults objectForKey:FB_LOGIN_USER_ID];
    NSString *name = [defaults objectForKey:FB_LOGIN_USER_NAME];
    NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", uid];
    
    [_userImage setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    [_username setText:name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
// Get the number of section in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"USER";
    else return @"GENERAL";
}

// Get the number of row in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 4;
    else return 2;
}

// Display the table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    UIImageView *cellIcon = (UIImageView *)[cell viewWithTag:300];
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:301];
    UIView *separator = (UIView *)[cell viewWithTag:302];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cellIcon setImage:[UIImage imageNamed:@"SubMenuNotificationIcon"]];
            cellLabel.text = @"Notifications";
            [separator setHidden:false];
        } else if (indexPath.row == 1) {
            [cellIcon setImage:[UIImage imageNamed:@"SubMenuPastEventsIcon"]];
            cellLabel.text = @"Past Events";
            [separator setHidden:false];
        } else if (indexPath.row == 2) {
            [cellIcon setImage:[UIImage imageNamed:@"SubMenuFavoriteIcon"]];
            cellLabel.text = @"Favorite Events";
            [separator setHidden:false];
        } else if (indexPath.row == 3) {
            [cellIcon setImage:[UIImage imageNamed:@"SubMenuTrashIcon"]];
            cellLabel.text = @"Hidden Events";
            [separator setHidden:true];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cellIcon setImage:[UIImage imageNamed:@"SubMenuSettingIcon"]];
            cellLabel.text = @"Settings";
            [separator setHidden:false];
        } else if (indexPath.row == 1) {
            [cellIcon setImage:[UIImage imageNamed:@"SubMenuLogoutIcon"]];
            cellLabel.text = @"Logout";
            [separator setHidden:true];
        }
    }
    return cell;
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 0) {
        if (indexPath.row ==0) [self performSegueWithIdentifier:@"notificationView" sender:Nil];
        else if (indexPath.row == 1) [self performSegueWithIdentifier:@"pastEventView" sender:Nil];
        else if (indexPath.row == 2) [self performSegueWithIdentifier:@"favoriteView" sender:Nil];
        else if (indexPath.row == 3) [self performSegueWithIdentifier:@"trashView" sender:Nil];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) [self performSegueWithIdentifier:@"settingView" sender:Nil];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
