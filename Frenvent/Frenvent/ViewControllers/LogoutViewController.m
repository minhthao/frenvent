//
//  LogoutViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/12/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "LogoutViewController.h"
#import "EventCoreData.h"
#import "FriendCoreData.h"
#import "NotificationCoreData.h"
#import "Constants.h"

@interface LogoutViewController ()

@end

@implementation LogoutViewController
#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:true];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    [EventCoreData removeAllEvents];
    [FriendCoreData removeAllFriends];
    [NotificationCoreData removeAllNotifications];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_LOGIN_USER_GENDER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_LOGIN_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_LOGIN_USER_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_DATA_INITIALIZED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WEBVIEW_LOGGED_IN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"loginView" sender:self];
}

@end
