//
//  FirstLoadingViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FirstLoadingViewController.h"
#import "FriendEventsRequest.h"
#import "EventCoreData.h"
#import "FriendToEventCoreData.h"
#import "FriendCoreData.h"

static NSInteger NUM_QUERIES = 5; //one for friends event, one for my events, one for friends, one for notification, one for nearby
NSInteger numQueriesLeft;


@interface FirstLoadingViewController ()

@end

@implementation FirstLoadingViewController 


- (void)viewDidLoad
{
    [super viewDidLoad];
    [EventCoreData removeAllEvents];
    [FriendToEventCoreData removeAllFriendToEventPairs];
    [FriendCoreData removeAllFriends];
    
    numQueriesLeft = 0;
    
    numQueriesLeft++;
    NSLog(@"%d", numQueriesLeft);
    
    FriendEventsRequest *friendEventsRequest = [[FriendEventsRequest alloc] init];
    [friendEventsRequest setDelegate:self];
    
//    [FriendEventsRequest initFriendEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegates
- (void) notifyFriendEventsQueryCompleted {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
