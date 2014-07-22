//
//  FriendInfoViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "FbUserInfoRequest.h"
#import "FbUserInfo.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface FriendInfoViewController ()

@property (nonatomic, strong) FbUserInfoRequest *fbUserInfoRequest;

@end

@implementation FriendInfoViewController
#pragma mark - initiation
- (FbUserInfoRequest *)fbUserInfoRequest {
    if (_fbUserInfoRequest == nil) {
        _fbUserInfoRequest = [[FbUserInfoRequest alloc] init];
        _fbUserInfoRequest.delegate = self;
    }
    return _fbUserInfoRequest;
}

#pragma mark - Fb user info request delegate
-(void) notifyFbUserInfoRequestFail {
    
}

/**
 * Notify if the user info request has completed.
 * @return FbUserInfo
 */
-(void) notifyFbUserInfoRequestCompletedWithResult:(FbUserInfo *)fbUserInfo {
    self.username.text = fbUserInfo.name;
    self.numMutualFriends.text = [NSString stringWithFormat:@"%d mutual friends", (int32_t)[fbUserInfo.mutualFriends count]];
    
    NSString *profilePictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", fbUserInfo.uid];
    [self.profileImage setImageWithURL:[NSURL URLWithString:profilePictureUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    
    [self.coverImage setImageWithURL:[NSURL URLWithString:fbUserInfo.cover] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
}


#pragma mark - public class to set the friend before the segue
/**
 * Set the friend and start the query to display
 * @param friend
 */
-(void) setFriend:(Friend *)friend {
    [[self fbUserInfoRequest] queryFriendInfo:friend];
}

#pragma mark - view delegate
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.userInfoTable setHidden:false];
    [self.recommendFriendTable setHidden:true];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view segment
- (IBAction)viewSegments:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger index = [segmentedControl selectedSegmentIndex];
    
    if (index == 0) {
        [self.userInfoTable setHidden:false];
        [self.recommendFriendTable setHidden:true];
    }
    if (index == 1) {
        [self.userInfoTable setHidden:true];
        [self.recommendFriendTable setHidden:false];
    }
    
}

@end
