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
#import "EventCoreData.h"
#import "Event.h"
#import "TimeSupport.h"

@interface MoreTableViewController ()

@property (nonatomic, strong) NSArray *allEvents;
@property (nonatomic, strong) NSArray *searchEvents;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@end

@implementation MoreTableViewController

#pragma mark - instantiation
//lazily instantiate all events
- (NSArray *)allEvents {
    if (_allEvents == nil) _allEvents = [EventCoreData getAllOngoingEvents];
    return _allEvents;
}

//instantiate search events
- (NSArray *)searchEvents {
    if (_searchEvents == nil) _searchEvents = [[NSArray alloc] init];
    return _searchEvents;
}

//get the uid
- (NSString *)uid {
    if (_uid == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _uid = [defaults objectForKey:FB_LOGIN_USER_ID];
    }
    return _uid;
}

//get the name
- (NSString *)name {
    if (_name == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _name = [defaults objectForKey:FB_LOGIN_USER_NAME];
    }
    return _name;
}

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
// Get the number of section in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_searchBar.text == nil || [_searchBar.text length] == 0) return 3;
    else return 1;
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_searchBar.text == nil || [_searchBar.text length] == 0) {
        if (section == 1) return @"USER";
        else if (section == 2) return @"GENERAL";
    }
    return nil;
}

// Get the number of row in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchBar.text == nil || [_searchBar.text length] == 0) {
        if (section == 0) return 1;
        if (section == 1) return 4;
        else return 2;
    } else return [[self searchEvents] count];
}

// unless it is the first row in menu table, we will enable selection
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((_searchBar.text == nil || [_searchBar.text length] == 0) && indexPath.section == 0) return false;
    return true;
}

// Give an high of table view cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchBar.text == nil || [_searchBar.text length] == 0) return 40.0;
    else return 70.0;
}

// Give an estimate to the height of table. For optimization purpose
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchBar.text == nil || [_searchBar.text length] == 0) return 40.0;
    else return 70.0;
}

// Display the table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchBar.text == nil || [_searchBar.text length] == 0)
        return [self displayMenuTableViewCell:_tableView forRowAtIndexPath:indexPath];
    else return [self displayEventTableViewCell:_tableView forRowAtIndexPath:indexPath];
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchBar.text == nil || [_searchBar.text length] == 0)
        [self handleMenuItemSelection:_tableView forRowAtIndexPath:indexPath];
    else [self handleSeachItemSelection:_tableView forRowAtIndexPath:indexPath];
}

#pragma mark - menu table functions
/**
 * Display the menu table item cell
 * @param table view
 * @param index path
 * @return Table View Cell
 */
- (UITableViewCell *)displayMenuTableViewCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userInfoMenuItem" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userInfoMenuItem"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", [self uid]];
        UIImageView *profilePic = (UIImageView *)[cell viewWithTag:350];
        UILabel *profileName = (UILabel *)[cell viewWithTag:351];
        [profilePic setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
        profileName.text = [self name];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuItem" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuItem"];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor orangeColor];
        [cell setSelectedBackgroundView:bgColorView];
        
        UIImageView *cellIcon = (UIImageView *)[cell viewWithTag:300];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:301];
        UIView *separator = (UIView *)[cell viewWithTag:302];
        
        if (indexPath.section == 1) {
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
        } else if (indexPath.section == 2) {
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
}

/**
 * Handle the selection of menu item
 * @param table view
 * @param index path
 */
- (void)handleMenuItemSelection:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 1) {
        if (indexPath.row ==0) [self performSegueWithIdentifier:@"notificationView" sender:Nil];
        else if (indexPath.row == 1) [self performSegueWithIdentifier:@"pastEventView" sender:Nil];
        else if (indexPath.row == 2) [self performSegueWithIdentifier:@"favoriteView" sender:Nil];
        else if (indexPath.row == 3) [self performSegueWithIdentifier:@"trashView" sender:Nil];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) [self performSegueWithIdentifier:@"settingView" sender:Nil];
        else if (indexPath.row == 1) {
            //todo handle logout
        }
    }
}

#pragma mark - search table function
/**
 * Display the table view cell for searched result
 * @param table view
 * @param index path
 * @return table view cell
 */
- (UITableViewCell *)displayEventTableViewCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchEventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchEventItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    Event *event = [_searchEvents objectAtIndex:indexPath.row];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:375];
    UILabel *eventName = (UILabel *)[cell viewWithTag:376];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:377];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:378];
    
    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    return cell;
}

// handle event item selection
- (void)handleSeachItemSelection:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    Event *event = [[self searchEvents] objectAtIndex:indexPath.row];
    NSLog(@"Select event : %@", event.name);
}

#pragma mark - search bar delegate
//handle the case where the new item is typed in the search
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        _searchEvents = [[self allEvents] filteredArrayUsingPredicate:resultPredicate];
    } else {
        _searchEvents = [[NSArray alloc] init];
    }
    
    [_tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
