//
//  FriendEventsViewControllerTableViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/6/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendEventsTableViewController.h"
#import "EventCoreData.h"
#import "Event.h"
#import "EventManager.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "TimeSupport.h"

@interface FriendEventsTableViewController ()

@property (nonatomic, strong) EventManager *eventManager;

@end

@implementation FriendEventsTableViewController

#pragma mark - private class
- (EventManager *) eventManager {
    if (_eventManager == nil) {
        _eventManager = [[EventManager alloc] init];
        [self.eventManager setEvents:[EventCoreData getFriendsEvents]];
    }
    
    return _eventManager;
}

#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
// Get the number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self eventManager] getNumberOfSections];
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self eventManager] getTitleAtSection:section];
}

// Get the number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self eventManager] getEventsAtSection:section] count];
}


// Get the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventItem"];
    }
    
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    UIView *containerView = (UIView *)[cell viewWithTag:200];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    UIView *selectionView = (UIView *)[cell viewWithTag:206];
    [selectionView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [selectionView.layer setBorderWidth:0.5f];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:201];
    UILabel *eventName = (UILabel *)[cell viewWithTag:202];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:203];
    UILabel *eventFriendsInterested = (UILabel *)[cell viewWithTag:204];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:205];

    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;
    eventFriendsInterested.attributedText = [event getFriendsInterestedAttributedString];
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];

    return cell;
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
