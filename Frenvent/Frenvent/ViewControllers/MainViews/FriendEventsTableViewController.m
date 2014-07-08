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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventItem"];
    }
    
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = event.name;
    NSLog(@"%@", event.picture);
    [cell.imageView setImageWithURL:[NSURL URLWithString:event.picture]];

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
