//
//  InvitedEventsTableViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/8/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "InvitedEventsTableViewController.h"
#import "MyEventManager.h"
#import "EventCoreData.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "TimeSupport.h"
#import "EventButton.h"
#import "MyColor.h"
#import "MyEventsRequest.h"
#import "Reachability.h"
#import "EventDetailViewController.h"
#import "ToastView.h"
#import "UITableView+NXEmptyView.h"

CLLocation *lastKnown;

@interface InvitedEventsTableViewController ()
@property (nonatomic, strong) MyEventManager *eventManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIRefreshControl *uiRefreshControl;
@property (nonatomic, strong) MyEventsRequest *myEventsRequest;

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation InvitedEventsTableViewController
#pragma mark - instantiation
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
        noResult.text = @"No invited events";
        [_emptyView addSubview:noResult];
    }
    return _emptyView;
}

/**
 * Lazily instantiate and get the event manager object
 * @return Event Manager
 */
- (MyEventManager *) eventManager {
    if (_eventManager == nil) {
        _eventManager = [[MyEventManager alloc] init];
        [self.eventManager setRepliedEvents:[EventCoreData getUserRepliedOngoingEvents] unrepliedEvents:[EventCoreData getUserUnrepliedOngoingEvents]];
    }
    
    return _eventManager;
}

/**
 * Lazily instantiate and get the event manager object
 * @return Event Manager
 */
- (MyEventManager *) eventManager:(CLLocation *)currentLocation {
    if (_eventManager == nil) {
        _eventManager = [[MyEventManager alloc] init];
        [self.eventManager setRepliedEvents:[EventCoreData getUserRepliedOngoingEvents] unrepliedEvents:[EventCoreData getUserUnrepliedOngoingEvents] withCurrentLocation:currentLocation];
    }
    return _eventManager;
}

/**
 * Lazily obtain the managed object context
 * @return Location manager
 */
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

/**
 * Lazily create and obtain refresh control
 * @return UI refresh control
 */
- (UIRefreshControl *)uiRefreshControl {
    if (_uiRefreshControl == nil) {
        _uiRefreshControl = [[UIRefreshControl alloc] init];
        // Configure Refresh Control
        [_uiRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        
        // Configure View Controller
        [self setRefreshControl:_uiRefreshControl];
    }
    return _uiRefreshControl;
}

/**
 * Lazily create and obtain my event request
 * @return friend event request
 */
- (MyEventsRequest *)myEventsRequest {
    if (_myEventsRequest ==  nil) {
        _myEventsRequest = [[MyEventsRequest alloc] init];
        _myEventsRequest.delegate = self;
    }
    return _myEventsRequest;
}

#pragma mark - refresh control methods
- (void)refresh:(id)sender {
    [self.refreshButton setEnabled:false];
    //we check if there is a internet connection, if no then stop refreshing and alert
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
            [[self locationManager] startUpdatingLocation];
        else [[self myEventsRequest] refreshMyEvents];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        [[self uiRefreshControl] endRefreshing];
        [self.refreshButton setEnabled:true];
    }
}

- (IBAction)doRefresh:(id)sender {
    [[self uiRefreshControl] beginRefreshing];
    [self refresh:[self uiRefreshControl]];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - [self uiRefreshControl].frame.size.height) animated:YES];
}

#pragma mark - delegate for my events request
- (void)notifyMyEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[self uiRefreshControl] endRefreshing];
    [self.refreshButton setEnabled:true];
}

- (void)notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    [[self eventManager]  setRepliedEvents:[EventCoreData getUserRepliedOngoingEvents] unrepliedEvents:[EventCoreData getUserUnrepliedOngoingEvents] withCurrentLocation:lastKnown];
    
    [self.tableView reloadData];
    [[self uiRefreshControl] endRefreshing];
    [self.refreshButton setEnabled:true];
}

#pragma mark - location manager delegates
//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[self locationManager] stopUpdatingLocation];
    
    if (locations != nil && [locations count] > 0) {
        lastKnown = [locations objectAtIndex:0];
        
        if (_eventManager == nil) [self eventManager:lastKnown];
        else if ([[self uiRefreshControl] isRefreshing]) [[self myEventsRequest] refreshMyEvents];
        else {
            [self.eventManager setCurrentLocation:[locations objectAtIndex:0]];
            [self.tableView reloadData];
        }

    }
}

// End refreshing if the cl location manager encounter error
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([[self uiRefreshControl] isRefreshing]) [[self myEventsRequest] refreshMyEvents];
}

#pragma mark - view delegate
//handle event when view first load
-(void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.tableView.nxEV_emptyView = [self emptyView];
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        [[self locationManager] startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:false];
}

//handle when it receive the memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate
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
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    [EventCoreData setEventMarkType:event withType:MARK_TYPE_HIDDEN];
    [[self eventManager] hideEventAtIndexPath:indexPath];
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Hide";
}

// Get the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:400];
    UILabel *eventName = (UILabel *)[cell viewWithTag:401];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:402];
    UILabel *eventFriendsInterested = (UILabel *)[cell viewWithTag:403];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:404];
    UILabel *eventDistance = (UILabel *)[cell viewWithTag:405];
    
    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;
    
    if ([event getRsvpAttributedString] != nil)
        eventFriendsInterested.attributedText = [event getRsvpAttributedString];
    else eventFriendsInterested.attributedText = [event getFriendsInterestedAttributedString];
    
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    eventDistance.text = [event getDistanceString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    //we check if there is a internet connection, if no then stop refreshing and alert
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"eventDetailView" sender:event.eid];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"eventDetailView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        NSString *eid = (NSString *)sender;
        EventDetailViewController *viewController = segue.destinationViewController;
        viewController.eid = eid;
    }
    
}

@end
