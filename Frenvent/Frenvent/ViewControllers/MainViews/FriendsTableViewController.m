//
//  FriendsTableViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "FriendManager.h"
#import "FriendCoreData.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "FbUserInfoViewController.h"
#import "TimeSupport.h"
#import "UITableView+NXEmptyView.h"
#import "MyColor.h"
#import "ToastView.h"

@interface FriendsTableViewController ()

@property (nonatomic, strong) FriendManager *friendManager;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) NSMutableSet *favoriteFriends;

@end

@implementation FriendsTableViewController

NSArray *allFriends;

#pragma mark - private class
-(UIView *)emptyView {
    if (_emptyView == nil) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.tableView.frame.size.height)];
        _emptyView.backgroundColor = [MyColor eventCellButtonNormalBackgroundColor];
        
        UILabel *noResult = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height/2 - 50, 320, 36)];
        noResult.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
        noResult.textColor = [MyColor eventCellButtonsContainerBorderColor];
        noResult.shadowColor = [UIColor whiteColor];
        noResult.textAlignment = NSTextAlignmentCenter;
        noResult.shadowOffset = CGSizeMake(1, 1);
        noResult.text = @"No matches";
        [_emptyView addSubview:noResult];
    }
    return _emptyView;
}

- (FriendManager *) friendManager {
    if (_friendManager == nil) {
        _favoriteFriends = [[NSMutableSet alloc] init];
        _friendManager = [[FriendManager alloc] init];
        allFriends = [FriendCoreData getAllFriends];
        for (Friend *friend in allFriends) 
            if ([friend.favorite boolValue]) [_favoriteFriends addObject:friend.uid];
        [self.friendManager setFriends:[FriendCoreData getAllFriends]];
    }
    
    return _friendManager;
}

#pragma mark - view controller methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.tableView.nxEV_emptyView = [self emptyView];
    [self.searchDisplayController.searchBar setTranslucent:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//Get the number of seccion in table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self friendManager].sectionTitles count];
}

//Get the title for the header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self friendManager].sectionTitles objectAtIndex:section];
}

//get the number of items in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:section];
    NSMutableArray *sectionEvents = [[self friendManager] getSectionedFriendsList:sectionTitle];
    return [sectionEvents count];
}

//Get the index title for index searching
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self friendManager] getCharacterIndices];
}

//Get the index of the title
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self friendManager].sectionTitles indexOfObject:title];
}

//Display the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
    Friend *friend = [sectionFriends objectAtIndex:indexPath.row];
    
    UIImageView *profilePicture = (UIImageView *)[cell viewWithTag:101];
    UILabel *username = (UILabel *)[cell viewWithTag:102];
    UIImageView *mark = (UIImageView *)[cell viewWithTag:103];
    if ([self.favoriteFriends containsObject:friend.uid]) mark.hidden = false;
    else mark.hidden = true;
    
    NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", friend.uid];
    [profilePicture setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    username.text = friend.name;
    
    return cell;
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
        Friend *friend = [sectionFriends objectAtIndex:indexPath.row];

        [self performSegueWithIdentifier:@"friendInfoView" sender:friend.uid];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return(YES);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
    Friend *friend = [sectionFriends objectAtIndex:indexPath.row];

    if ([self.favoriteFriends containsObject:friend.uid]) return @"Unfollow      ";
    else return @"Follow      ";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
    Friend *friend = [sectionFriends objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *mark = (UIImageView *)[cell viewWithTag:103];

    if (![self.favoriteFriends containsObject:friend.uid]) {
        [self.favoriteFriends addObject:friend.uid];
        [FriendCoreData setFriend:friend toFavorite:true];
        mark.hidden = false;
    } else if ([self.favoriteFriends count] <= 20) {
        [ToastView showToastOnTopOfParentView:self.view withText:@"Cannot have less than 20 favorite friends" withDuaration:2];
    } else {
        [self.favoriteFriends removeObject:friend.uid];
        [FriendCoreData setFriend:friend toFavorite:false];
        mark.hidden = true;
    }
}

#pragma mark - search bar delegate
//handle the case where the new item is typed in the search
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        NSArray *searchResults = [allFriends filteredArrayUsingPredicate:resultPredicate];
        [[self friendManager] setFriends:searchResults];
    } else [[self friendManager] setFriends:allFriends];
    
    [self.tableView reloadData];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"friendInfoView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        NSString *uid = (NSString *)sender;
        FbUserInfoViewController *viewController = segue.destinationViewController;
        viewController.shouldReadjustInset = true;
        viewController.targetUid = uid;
    }
}

@end
