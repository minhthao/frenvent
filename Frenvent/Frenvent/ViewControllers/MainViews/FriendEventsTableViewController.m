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
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "TimeSupport.h"
#import "EventButton.h"
#import "MyColor.h"
#import "Reachability.h"
#import "EventDetailViewController.h"
#import "EventRsvpRequest.h"
#import "ShareEventRequest.h"
#import "ToastView.h"
#import "UITableView+NXEmptyView.h"

CLLocation *lastKnown;

@interface FriendEventsTableViewController ()

@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic, strong) UIActionSheet *rsvpActionSheet;
@property (nonatomic, strong) EventRsvpRequest *eventRsvpRequest;
@property (nonatomic, strong) NSIndexPath *indexPathOfRsvpEvent;

@property (nonatomic, strong) UIActionSheet *shareActionSheet;
@property (nonatomic, strong) ShareEventRequest *shareEventRequest;

@property (nonatomic, strong) UIActionSheet *filterActionSheet;

@property (nonatomic, strong) EventManager *eventManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIRefreshControl *uiRefreshControl;
@property (nonatomic, strong) FriendEventsRequest *friendEventsRequest;

@end

@implementation FriendEventsTableViewController

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
        noResult.text = @"No featured events";
        [_emptyView addSubview:noResult];
    }
    return _emptyView;
}

/**
 * Lazily instantiate the rsvp action sheet
 * @return rsvp action sheet
 */
- (UIActionSheet *)rsvpActionSheet {
    if (_rsvpActionSheet == nil) {
        _rsvpActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Going", @"Maybe", nil];
        _rsvpActionSheet.tag = 1;
    }
    return _rsvpActionSheet;
}

/**
 * Lazily instantiate the event rsvp request
 * @return rsvp request
 */
-(EventRsvpRequest *)eventRsvpRequest {
    if (_eventRsvpRequest ==  nil) {
        _eventRsvpRequest = [[EventRsvpRequest alloc] init];
        _eventRsvpRequest.delegate = self;
    }
    return _eventRsvpRequest;
}

/**
 * Lazily instantiate the share action sheet
 * @return share action sheet
 */
-(UIActionSheet *)shareActionSheet {
    if (_shareActionSheet == nil) {
        _shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share via messenger", @"Share on wall", nil];
        _shareActionSheet.tag = 2;
    }
    return _shareActionSheet;
}

/**
 * Lazily instantiate the share event request
 * @return Share event request
 */
-(ShareEventRequest *)shareEventRequest {
    if (_shareEventRequest == nil) {
        _shareEventRequest = [[ShareEventRequest alloc] init];
        _shareEventRequest.delegate = self;
    }
    return _shareEventRequest;
}

/**
 * Lazily instantiate the filter action sheet
 * @return filter action sheet
 */
- (UIActionSheet *)filterActionSheet {
    if (_filterActionSheet == nil) {
        _filterActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Default" destructiveButtonTitle:nil otherButtonTitles:@"< 5 mile", @"< 25 miles", @"< 50 miles", nil];
        _filterActionSheet.tag = 3;
        _filterActionSheet.delegate = self;
    }
    return _filterActionSheet;
}

/**
 * Lazily instantiate and get the event manager object
 * @return Event Manager
 */
- (EventManager *) eventManager {
    if (_eventManager == nil) {
        _eventManager = [[EventManager alloc] init];
        _eventManager.filterType = FILTER_TYPE_DEFAULT;
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
        [_eventManager setEvents:[EventCoreData getFriendsEvents] withCurrentLocation:currentLocation];
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
 * Lazily create and obtain friend event request
 * @return friend event request
 */
- (FriendEventsRequest *)friendEventsRequest {
    if (_friendEventsRequest ==  nil) {
        _friendEventsRequest = [[FriendEventsRequest alloc] init];
        _friendEventsRequest.delegate = self;
    }
    return _friendEventsRequest;
}

#pragma mark - refresh control methods
-(void)refresh:(id)sender {
    [self.refreshButton setEnabled:false];
    //we check if there is a internet connection, if no then stop refreshing and alert
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            [[self locationManager] startUpdatingLocation];
        } else [[self friendEventsRequest] refreshFriendEvents];
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

#pragma mark - UIActionSheet and rsvp delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        Event *event = [[[self eventManager] getEventsAtSection:self.indexPathOfRsvpEvent.section] objectAtIndex:self.indexPathOfRsvpEvent.row];
        switch (buttonIndex) {
            case 0:
                if (![event.rsvp isEqualToString:RSVP_ATTENDING])
                    [[self eventRsvpRequest] replyAttendingToEvent:event.eid];
                break;
            case 1:
                if (![event.rsvp isEqualToString:RSVP_UNSURE])
                    [[self eventRsvpRequest] replyUnsureToEvent:event.eid];
                break;
            default:
                break;
        }
    } else if (actionSheet.tag == 2) {
        Event *event = [[[self eventManager] getEventsAtSection:self.indexPathOfRsvpEvent.section] objectAtIndex:self.indexPathOfRsvpEvent.row];
        switch (buttonIndex) {
            case 0:
                [[self shareEventRequest] shareToFriendTheEventWithEid:event.eid];
                break;
                
            case 1:
                [[self shareEventRequest] shareToWallTheEvent:event.eid];
                break;
                
            default:
                break;
        }
    } else if (actionSheet.tag == 3) {
        switch (buttonIndex) {
            case 0:
                self.filterButton.title = @"< 5 mile";
                break;
                
            case 1:
                self.filterButton.title = @"< 25 miles";
                break;
                
            case 2:
                self.filterButton.title = @"< 50 miles";
                break;
                
            case 3:
                self.filterButton.title = @"Filter";
                break;
                
            default:
                break;
        }
        
        [[self eventManager] filterEvent:buttonIndex];
        [self.tableView reloadData];
    }
}

-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvp {
    if (success) {
        Event *event = [[[self eventManager] getEventsAtSection:self.indexPathOfRsvpEvent.section] objectAtIndex:self.indexPathOfRsvpEvent.row];
        [[self eventManager] changeRsvpOfEventAtIndexPath:self.indexPathOfRsvpEvent withRsvp:rsvp];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPathOfRsvpEvent];
        UILabel *eventFriendsInterested = (UILabel *)[cell viewWithTag:204];
        if ([event getRsvpAttributedString] != nil)
            eventFriendsInterested.attributedText = [event getRsvpAttributedString];
        else eventFriendsInterested.attributedText = [event getFriendsInterestedAttributedString];
        
        [ToastView showToastInParentView:self.view withText:@"Event successfully RSVP" withDuaration:3.0];
    } else [ToastView showToastInParentView:self.view withText:@"Fail to RSVP event" withDuaration:3.0];
}

-(void)notifyShareEventRequestSuccess:(BOOL)success {
    if (success) [ToastView showToastInParentView:self.view withText:@"Event shared successfully" withDuaration:3.0];
    else [ToastView showToastInParentView:self.view withText:@"Fail to share event" withDuaration:3.0];
}

#pragma mark - delegate for friend events request
- (void)notifyFriendEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    if (lastKnown != nil) [[self eventManager] setEvents:allEvents withCurrentLocation:lastKnown];
    else [[self eventManager] setEvents:allEvents];
    [self.tableView reloadData];
    
    [[self uiRefreshControl] endRefreshing];
    [self.refreshButton setEnabled:true];
}

- (void)notifyFriendEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[self uiRefreshControl] endRefreshing];
    [self.refreshButton setEnabled:true];
}

#pragma mark - location manager delegates
//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[self locationManager] stopUpdatingLocation];
    if (locations != nil && [locations count] > 0) {
        [self.filterButton setEnabled:true];
        lastKnown = [locations objectAtIndex:0];
        
        if (_eventManager == nil) [self eventManager:lastKnown];
        else if ([[self uiRefreshControl] isRefreshing]) [[self friendEventsRequest] refreshFriendEvents];
        else {
            [self.eventManager setEvents:[EventCoreData getFriendsEvents] withCurrentLocation:[locations objectAtIndex:0]];
            [self.tableView reloadData];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[self locationManager] stopUpdatingLocation];
    if ([[self uiRefreshControl] isRefreshing]) [[self friendEventsRequest] refreshFriendEvents];
}


#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.tableView.nxEV_emptyView = [self emptyView];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.filterButton setEnabled:false];
    self.refreshControl = [self uiRefreshControl];
    
    [_uiRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:false];
    
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        [[self locationManager] startUpdatingLocation];
    else if (_eventManager != nil) {
        [[self eventManager] setEvents:[EventCoreData getFriendsEvents]];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
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

// Customize the title
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 8, 300, 18);
    myLabel.font = [UIFont fontWithName:@"SourceSansPro-SemiBold" size:14];
    myLabel.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    UIView *labelContainer = [[UIView alloc] init];
    labelContainer.frame = CGRectMake(0, 0, screenWidth, 35);
    labelContainer.backgroundColor = [UIColor whiteColor];
    [labelContainer addSubview:myLabel];
    
    UIView *topBorber = [[UIView alloc] init];
    topBorber.frame = CGRectMake(0, 0, screenWidth, 1);
    topBorber.backgroundColor = [UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0];
    
    UIView *bottomBorder = [[UIView alloc] init];
    bottomBorder.frame = CGRectMake(0, 35, screenWidth, 1);
    bottomBorder.backgroundColor = [UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:labelContainer];
    if (section != 0) [headerView addSubview:topBorber];
    [headerView addSubview:bottomBorder];
    
    return headerView;
}

// Customize the height for the title
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 48;
}

// Get the number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self eventManager] getEventsAtSection:section] count];
}

// Get the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventItem"];
    
    UIView *containerView = (UIView *)[cell viewWithTag:200];
    [containerView.layer setCornerRadius:4.0f];
    [containerView.layer setMasksToBounds:YES];
    
    UIView *shadowView = (UIView *)[cell viewWithTag:199];
    [shadowView.layer setCornerRadius:4.0f];
    [shadowView.layer setMasksToBounds:NO];
    [shadowView.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [shadowView.layer setShadowRadius:3];
    [shadowView.layer setShadowOffset:CGSizeMake(0, 1)];
    [shadowView.layer setShadowOpacity:0.25f];

    
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:201];
    UILabel *eventName = (UILabel *)[cell viewWithTag:202];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:203];
    UILabel *eventFriendsInterested = (UILabel *)[cell viewWithTag:204];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:205];
    UILabel *eventDistance = (UILabel *)[cell viewWithTag:206];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat notificationHeaderWidth = screenWidth - 125;
    [eventName setPreferredMaxLayoutWidth:notificationHeaderWidth];

    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;
    
    if ([event getRsvpAttributedString] != nil)
        eventFriendsInterested.attributedText = [event getRsvpAndAttendeesAttributedString];
    else eventFriendsInterested.attributedText = [event getFriendsInterestedAttributedString];
    
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    eventDistance.text = [event getDistanceString];
    
    //add the buttons
    UIView *buttonsBar = (UIView *)[cell viewWithTag:207];
    [buttonsBar setClipsToBounds:true];
    
    EventButton *shareButton = [self cellShareButton:indexPath];
    if (shareButton != nil) [buttonsBar addSubview:shareButton];
    
    EventButton *rsvpButton = [self cellRsvpButton:indexPath];
    if (rsvpButton != nil) [buttonsBar addSubview:rsvpButton];
    
    if (rsvpButton == nil && shareButton == nil) {
        EventButton *detailButton = [self cellDetailButton:indexPath];
        [buttonsBar addSubview:detailButton];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *containerView = (UIView *)[cell viewWithTag:200];
    [containerView setBackgroundColor:[UIColor orangeColor]];
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


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *containerView = (UIView *)[cell viewWithTag:200];
    [containerView setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - cell buttons
/**
 * Create and return the share button for a cell at a given index path
 * @param index path
 */
- (EventButton *)cellShareButton:(NSIndexPath *)indexPath {
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    if (![event canShare]) return nil;
    
    float width = self.tableView.frame.size.width - 20; //for padding
    //otherwise we create that button
    CGRect buttonFrame = CGRectMake(width/2, 0.0, width/2, 44.0); //all 2 buttons presents
    EventButton *shareButton = [[EventButton alloc] initWithFrame:buttonFrame];
    
    //set title and format button
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"EventCellShareIcon"] forState:UIControlStateNormal];
    [shareButton setImageEdgeInsets:(UIEdgeInsetsMake(0.0, 0.0, 1.0, 8.0))];
    
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
    
    float width = self.tableView.frame.size.width - 20; //for padding
    CGRect buttonFrame;
    if ([event canShare])  //can share implies can rsvp
        buttonFrame = CGRectMake(0.0, 0.0, width/2, 44.0);
    else if ([event canRsvp])
        buttonFrame = CGRectMake(0.0, 0.0, width, 44.0);
    else return nil; //no need to create this button
    
    EventButton *rsvpButton = [[EventButton alloc] initWithFrame:buttonFrame];
    
    //set title and format button
    [rsvpButton setTitle:@"RSVP" forState:UIControlStateNormal];
    [rsvpButton setImage:[UIImage imageNamed:@"EventCellRsvpIcon"] forState:UIControlStateNormal];
    [rsvpButton setImageEdgeInsets:(UIEdgeInsetsMake(0.0, 0.0, 1.0, 8.0))];
    
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
    float width = self.tableView.frame.size.width - 20; //for padding
    CGRect buttonFrame = CGRectMake(0.0, 0.0, width, 44.0); //only this button present
    
    EventButton *detailButton = [[EventButton alloc] initWithFrame:buttonFrame];
    
    //set title and format button
    [detailButton setTitle:@"Detail" forState:UIControlStateNormal];
    [detailButton setImage:[UIImage imageNamed:@"EventCellDetailIcon"] forState:UIControlStateNormal];
    [detailButton setImageEdgeInsets:(UIEdgeInsetsMake(0.0, 0.0, 1.0, 8.0))];
    
    //set the index path to recognize which event the button is resided to configured its actions.
    detailButton.indexPath = indexPath;
    [detailButton addTarget:self action:@selector(detailActionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return detailButton;
}

#pragma mark - cell button actions selector
//Handle the event when the the share button for a given event is pressed
- (void)shareActionPressed:(EventButton *)sender{
    self.indexPathOfRsvpEvent = sender.indexPath;
    Event *event = [[[self eventManager] getEventsAtSection:sender.indexPath.section] objectAtIndex:sender.indexPath.row];

    if ([FBDialogs canPresentMessageDialog])
        [[self shareActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    else [[self shareEventRequest] shareToWallTheEvent:event.eid];
}

//Handle the event when the the rsvp button for a given event is pressed
- (void)rsvpActionPressed:(EventButton *)sender{
    self.indexPathOfRsvpEvent = sender.indexPath;
    
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        [[self rsvpActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }

}

//Handle the event when the the detail button for a given event is pressed
- (void)detailActionPressed:(EventButton *)sender{
    Event *event = [[[self eventManager] getEventsAtSection:sender.indexPath.section] objectAtIndex:sender.indexPath.row];
    
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
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

- (IBAction)doFilter:(id)sender {
    [[self filterActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
}

@end
