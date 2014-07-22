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
#import "UIImageView+AFNetworking.h"
#import "Reachability.h"
#import "FriendInfoViewController.h"

@interface FriendsTableViewController ()

@property (nonatomic, strong) FriendManager *friendManager;

@end

@implementation FriendsTableViewController

NSArray *allFriends;

#pragma mark - private class
- (FriendManager *) friendManager {
    if (_friendManager == nil) {
        _friendManager = [[FriendManager alloc] init];
        allFriends = [FriendCoreData getAllFriends];
        [self.friendManager setFriends:[FriendCoreData getAllFriends]];
    }
    
    return _friendManager;
}

#pragma mark - view controller methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:true];
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
    
    NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", friend.uid];
    [profilePicture setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    username.text = friend.name;
    
    return cell;
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    internetReachable.reachableBlock = ^(Reachability*reach) {
        [self performSegueWithIdentifier:@"friendInfoView" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    };
    internetReachable.unreachableBlock = ^(Reachability*reach) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    };
    
    [internetReachable startNotifier];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
        Friend *friend = [sectionFriends objectAtIndex:indexPath.row];

        FriendInfoViewController *viewController = segue.destinationViewController;
        [segue.destinationViewController setDetail:item];
    }
}

@end
