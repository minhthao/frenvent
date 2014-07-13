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
#import "FriendEventsRequest.h"
#import "EventManager.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "TimeSupport.h"
#import "EventButton.h"
#import "MyColor.h"

@interface FriendEventsTableViewController ()

@property (nonatomic, strong) EventManager *eventManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation FriendEventsTableViewController

#pragma mark - private class
/**
 * Lazily instantiate and get the event manager object
 * @return Event Manager
 */
- (EventManager *) eventManager {
    if (_eventManager == nil) {
        _eventManager = [[EventManager alloc] init];
        [self.eventManager setEvents:[EventCoreData getFriendsEvents]];
    }
    
    return _eventManager;
}

/**
 * Lazily instantiate and get the event manager object
 * @return Event Manager
 */
- (EventManager *) eventManager:(CLLocation *)currentLocation {
    if (_eventManager == nil) {
        _eventManager = [[EventManager alloc] init];
        [self.eventManager setEvents:[EventCoreData getFriendsEvents] withCurrentLocation:currentLocation];
    }
    return _eventManager;
}

/**
 * Lazily obtain the managed object context
 * @return location manager
 */
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

#pragma mark - location manager delegates
//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations != nil && [locations count] > 0) {
        if (_eventManager == nil) [self eventManager:[locations objectAtIndex:0]];
        else {
            [self.eventManager setCurrentLocation:[locations objectAtIndex:0]];
            [self.tableView reloadData];
        }
    }
    [[self locationManager] stopUpdatingLocation];
}


#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:true];
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [[self locationManager] startUpdatingLocation];
    }
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

// Override to support conditional editing of the table view.
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return(YES);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Deleted row.");
}


// Get the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventItem"];
    
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    UIView *containerView = (UIView *)[cell viewWithTag:200];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:201];
    UILabel *eventName = (UILabel *)[cell viewWithTag:202];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:203];
    UILabel *eventFriendsInterested = (UILabel *)[cell viewWithTag:204];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:205];
    UILabel *eventDistance = (UILabel *)[cell viewWithTag:206];

    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;
    
    if ([event getRsvpAttributedString] != nil)
        eventFriendsInterested.attributedText = [event getRsvpAttributedString];
    else eventFriendsInterested.attributedText = [event getFriendsInterestedAttributedString];
    
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    eventDistance.text = [event getDistanceString];
    
    //add the buttons
    UIView *buttonsBar = (UIView *)[cell viewWithTag:207];
    [buttonsBar.layer setBorderColor:[[MyColor eventCellButtonsContainerBorderColor] CGColor]];
    [buttonsBar.layer setBorderWidth:0.5f];
    
    EventButton *shareButton = [self cellShareButton:indexPath];
    if (shareButton != nil) [buttonsBar addSubview:shareButton];
    
    EventButton *rsvpButton = [self cellRsvpButton:indexPath];
    if (rsvpButton != nil) [buttonsBar addSubview:rsvpButton];
    
    EventButton *detailButton = [self cellDetailButton:indexPath];
    [buttonsBar addSubview:detailButton];
    
    return cell;
}

#pragma mark - cell buttons
/**
 * Create and return the share button for a cell at a given index path
 * @param index path
 */
- (EventButton *)cellShareButton:(NSIndexPath *)indexPath {
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    if (![event canShare]) return nil;
    
    //otherwise we create that button
    CGRect buttonFrame = CGRectMake(207.0, 0.0, 103.0, 35.0); //all 3 buttons presents
    EventButton *shareButton = [[EventButton alloc] initWithFrame:buttonFrame];
    
    //set title and format button
    [shareButton setButtonTitle:@"Share"];
    [shareButton setImage:[UIImage imageNamed:@"EventCellShareIcon"] forState:UIControlStateNormal];
    [shareButton setImageEdgeInsets:(UIEdgeInsetsMake(0.0, 0.0, 1.0, 8.0))];
    [self formatEventCellButton:shareButton];
    
    //set the index path to recognize which event the button is resided to configured its actions.
    shareButton.indexPath = indexPath;
    [shareButton addTarget:self action:@selector(shareActionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return shareButton;
}

/**
 * Create and return the rsvp button for a cell at a given index path
 * @param index path
 */
- (EventButton *)cellRsvpButton:(NSIndexPath *)indexPath {
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    CGRect buttonFrame;
    if ([event canShare])  //can share implies can rsvp
        buttonFrame = CGRectMake(103.0, 0.0, 104.0, 35.0); //all 3 buttons presents
    else if ([event canRsvp])
        buttonFrame = CGRectMake(155.0, 0.0, 155.0, 35.0); //only 2 buttons presents
    else return nil; //no need to create this button
    
    EventButton *rsvpButton = [[EventButton alloc] initWithFrame:buttonFrame];
    
    //set title and format button
    [rsvpButton setButtonTitle:@"Rsvp"];
    [rsvpButton setImage:[UIImage imageNamed:@"EventCellRsvpIcon"] forState:UIControlStateNormal];
    [rsvpButton setImageEdgeInsets:(UIEdgeInsetsMake(0.0, 0.0, 1.0, 8.0))];
    [self formatEventCellButton:rsvpButton];
    
    //set the index path to recognize which event the button is resided to configured its actions.
    rsvpButton.indexPath = indexPath;
    [rsvpButton addTarget:self action:@selector(rsvpActionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return rsvpButton;
}

/**
 * Create and return the detail button for a cell at a given index path
 * @param index path
 */
- (EventButton *)cellDetailButton:(NSIndexPath *)indexPath {
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    CGRect buttonFrame;
    if ([event canShare])  //can share implies can rsvp
        buttonFrame = CGRectMake(0.0, 0.0, 103.0, 35.0); //all 3 buttons presents
    else if ([event canRsvp])
        buttonFrame = CGRectMake(0.0, 0.0, 155.0, 35.0); //only 2 buttons presents
    else buttonFrame = CGRectMake(0.0, 0.0, 310.0, 35.0); //only this button present
    
    EventButton *detailButton = [[EventButton alloc] initWithFrame:buttonFrame];
    
    //set title and format button
    [detailButton setButtonTitle:@"Detail"];
    [detailButton setImage:[UIImage imageNamed:@"EventCellDetailIcon"] forState:UIControlStateNormal];
    [detailButton setImageEdgeInsets:(UIEdgeInsetsMake(0.0, 0.0, 1.0, 8.0))];
    [self formatEventCellButton:detailButton];
    
    //set the index path to recognize which event the button is resided to configured its actions.
    detailButton.indexPath = indexPath;
    [detailButton addTarget:self action:@selector(detailActionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return detailButton;
}


#pragma mark - format event cell button
/**
 * Format the event cell buttons. This include the behavior when highlight and font
 * @param Event button
 */
- (void)formatEventCellButton:(EventButton *)button {
    [button setBackgroundImage:[MyColor imageWithColor:[MyColor eventCellButtonNormalBackgroundColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[MyColor imageWithColor:[MyColor eventCellButtonHighlightBackgroundColor]] forState:UIControlStateHighlighted];
    
    [button setTitleColor:[MyColor eventCellButtonNormalTextColor] forState:UIControlStateNormal];
    [button setTitleColor:[MyColor eventCellButtonHighlightTextColor] forState:UIControlStateHighlighted];
    
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.5]];

}

#pragma mark - cell button actions selector
//Handle the event when the the share button for a given event is pressed
- (void)shareActionPressed:(EventButton *)sender{
    Event *event = [[[self eventManager] getEventsAtSection:sender.indexPath.section] objectAtIndex:sender.indexPath.row];
    NSLog(@"share pressed for event: %@", event.name);
}

//Handle the event when the the rsvp button for a given event is pressed
- (void)rsvpActionPressed:(EventButton *)sender{
    Event *event = [[[self eventManager] getEventsAtSection:sender.indexPath.section] objectAtIndex:sender.indexPath.row];
    NSLog(@"rsvp pressed for event: %@", event.name);
}

//Handle the event when the the detail button for a given event is pressed
- (void)detailActionPressed:(EventButton *)sender{
    Event *event = [[[self eventManager] getEventsAtSection:sender.indexPath.section] objectAtIndex:sender.indexPath.row];
    NSLog(@"detail pressed for event: %@", event.name);
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
