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
    
    UITextField *textField = [[self.searchDisplayController.searchBar subviews] objectAtIndex:1];
    [textField setFont:[UIFont fontWithName:@"SourceSansPro-Regular" size:13]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        self.navigationController.hidesBarsOnSwipe = NO;
    }
    
    CGRect navFrame =  self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(0, 20, navFrame.size.width, navFrame.size.height);
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

// Customize the title
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(5, 0, 300, 25);
    myLabel.font = [UIFont fontWithName:@"SourceSansPro-SemiBold" size:15];
    myLabel.textColor = [UIColor colorWithRed:23/255.0 green:23/255.0 blue:23/255.0 alpha:1.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    UIView *labelContainer = [[UIView alloc] init];
    labelContainer.frame = CGRectMake(0, 0, screenWidth, 25);
    labelContainer.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    [labelContainer addSubview:myLabel];
    
    UIView *topBorber = [[UIView alloc] init];
    topBorber.frame = CGRectMake(0, 0, screenWidth, 1);
    topBorber.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    
    UIView *bottomBorder = [[UIView alloc] init];
    bottomBorder.frame = CGRectMake(0, 25, screenWidth, 1);
    bottomBorder.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:labelContainer];
    if (section != 0) [headerView addSubview:topBorber];
    [headerView addSubview:bottomBorder];
    
    return headerView;
}

// Customize the height for the title
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 26;
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
    if ([self.favoriteFriends containsObject:friend.uid] || !self.editButton.selected) {
        [profilePicture setAlpha:1.0];
        [username setTextColor:[UIColor colorWithRed:23/255.0 green:23/255.0 blue:23/255.0 alpha:1.0]];
    } else {
        [profilePicture setAlpha:0.3];
        [username setTextColor:[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0]];

    }
    
    NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", friend.uid];
    [profilePicture setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    username.text = friend.name;
    
    return cell;
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
    Friend *friend = [sectionFriends objectAtIndex:indexPath.row];
    
    if (self.editButton.selected) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *mark = (UIImageView *)[cell viewWithTag:103];
        
        if (![self.favoriteFriends containsObject:friend.uid]) {
            [self.favoriteFriends addObject:friend.uid];
            [FriendCoreData setFriend:friend toFavorite:true];
            mark.hidden = false;
        } else {
            [self.favoriteFriends removeObject:friend.uid];
            [FriendCoreData setFriend:friend toFavorite:false];
            mark.hidden = true;
        }
        [self.tableView reloadData];
    } else {
        Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
        if ([internetReachable isReachable])
            [self performSegueWithIdentifier:@"friendInfoView" sender:friend.uid];
        else {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                              message:@"Connect to internet and try again."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - search bar delegate
//handle the case where the new item is typed in the search
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.navigationController setNavigationBarHidden:YES animated:false];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
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
        viewController.targetUid = uid;
    }
}

- (IBAction)edit:(id)sender {
    if (self.editButton.selected) [self.editButton setSelected:NO];
    else [self.editButton setSelected:YES];
    [self.tableView reloadData];
}

@end
