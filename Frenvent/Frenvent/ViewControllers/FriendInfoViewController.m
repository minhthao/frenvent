//
//  FriendInfoViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "FbUserInfoRequest.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "Friend.h"
#import "MyColor.h"

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
    NSLog(@"%d mutual friends", (int16_t)[mutualFriends count]);
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

#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.userInfoTable setHidden:false];
    [self.recommendFriendTable setHidden:true];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.profileImage.layer setMasksToBounds:YES];
    [self.profileImage.layer setBorderWidth:3];
    [self.profileImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];

    
    if (self.friend != nil) {
        NSString *profilePictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", self.friend.uid];
        [self.profileImage setImageWithURL:[NSURL URLWithString:profilePictureUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
        
        [[self fbUserInfoRequest] queryFbUserInfo:self.friend.uid];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
        [self.recommendFriendTable setHidden:true];
    }
    if (index == 1) {
        [self.userInfoTable setHidden:true];
        [self.recommendFriendTable setHidden:false];
    }
    
}

@end
