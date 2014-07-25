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

@interface FbUserInfoViewController ()

@property (nonatomic, strong) FbUserInfoRequest *fbUserInfoRequest;
@property (nonatomic, strong) NSArray *mutualFriends;

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

- (void)maskButtonView:(UIView *)view {
    [view.layer setCornerRadius:3.0f];
    [view.layer setMasksToBounds:YES];
    [view.layer setBorderWidth:2.5f];
    [view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
}

#pragma mark - alert view delegate
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
     [self.navigationController popViewControllerAnimated:true];
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

-(void) fbUserInfoRequestMutualFriends:(NSArray *)mutualFriends {
    if ([mutualFriends count] >0) {
        self.mutualFriends = mutualFriends;
        [self.mutualFriendsTable reloadData];
    }
    
    self.numMutualFriends.text = [NSString stringWithFormat:@"%d mutual friends", (int16_t)[mutualFriends count]];
}

-(void) fbUserInfoRequestName:(NSString *)name {
    self.username.text = name;
}

-(void) fbUserInfoRequestOngoingEvents:(NSArray *)onGoingEvents {
    NSLog(@"%d ongoing events", (int16_t)[onGoingEvents count]);
}

-(void) fbUserInfoRequestPastEvents:(NSArray *)pastEvents {
     NSLog(@"%d past events", (int16_t)[pastEvents count]);
}

-(void) fbUserInfoRequestProfileCover:(NSString *)cover {
    if ([cover length] > 0)
        [self.coverImage setImageWithURL:[NSURL URLWithString:cover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    else [self.coverImage setImage:[MyColor imageWithColor:[UIColor darkGrayColor]]];   
    
}

#pragma mark - button tap
- (void)handleProfileButtonTap:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"webView" sender:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", self.targetUid]];
}

- (void)handleMessageButtonTap:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"webView" sender:[NSString stringWithFormat:@"https://m.facebook.com/messages/compose?ids=%@", self.targetUid]];}

- (void)handlePhotoButtonTap:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"webView" sender:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?v=photos&id=%@", self.targetUid]];
}

- (void)handleFriendButtonTap:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"webView" sender:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?v=friends&id=%@", self.targetUid]];}

#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    [self fbUserInfoRequest];
    [self.userInfoTable setHidden:false];
    [self.mutualFriendsTable setHidden:true];
    
    UITapGestureRecognizer *profileButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileButtonTap:)];
    [self.profileButton addGestureRecognizer:profileButtonTap];
    
    UITapGestureRecognizer *messageButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMessageButtonTap:)];
    [self.messageButton addGestureRecognizer:messageButtonTap];
    
    UITapGestureRecognizer *photoButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePhotoButtonTap:)];
    [self.photoButton addGestureRecognizer:photoButtonTap];
    
    UITapGestureRecognizer *friendButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendButtonTap:)];
    [self.eventButton addGestureRecognizer:friendButtonTap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.profileImage.layer setMasksToBounds:YES];
    [self.profileImage.layer setBorderWidth:3];
    [self.profileImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [self maskButtonView:self.profileButton];
    [self maskButtonView:self.messageButton];
    [self maskButtonView:self.photoButton];
    [self maskButtonView:self.eventButton];
    
    if (self.targetUid != nil) {
        NSString *profilePictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", self.targetUid];
        [self.profileImage setImageWithURL:[NSURL URLWithString:profilePictureUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
        
        [[self fbUserInfoRequest] queryFbUserInfo:self.targetUid];
    }
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
        [self.userInfoTable setHidden:false];
        [self.mutualFriendsTable setHidden:true];
    }
    if (index == 1) {
        [self.userInfoTable setHidden:true];
        [self.mutualFriendsTable setHidden:false];
    }
}

#pragma mark - table view delegate
// Get the number of section in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([tableView isEqual:self.mutualFriendsTable]) return 1;
    else return 0;
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.mutualFriendsTable]) return @"Common friends";
    else return nil;
}

// Get the number of row in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mutualFriends count];
}


// Display the table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.mutualFriendsTable]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fbUserMutualFriend" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fbUserMutualFriend"];

        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor orangeColor];
        [cell setSelectedBackgroundView:bgColorView];

        UIImageView *profilePicture = (UIImageView *)[cell viewWithTag:1050];
        UILabel *username = (UILabel *)[cell viewWithTag:1051];
        
        Friend *friend = [self.mutualFriends objectAtIndex:indexPath.row];

        NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", friend.uid];
        [profilePicture setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
        username.text = friend.name;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fbUserSelectionMenu" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fbUserSelectionMenu"];
        return cell;
    }
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - segue preparation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToSelf"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.mutualFriendsTable indexPathForCell:cell];
        [self.mutualFriendsTable deselectRowAtIndexPath:indexPath animated:true];
        Friend *friend = [self.mutualFriends objectAtIndex:indexPath.row];
        FbUserInfoViewController *viewController = segue.destinationViewController;
        viewController.targetUid = friend.uid;
    } else if ([[segue identifier] isEqualToString:@"webView"]) {
        WebViewController *viewController = segue.destinationViewController;
        viewController.url = (NSString *)sender;
    }
}

@end
