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
@property (nonatomic, strong) UIRefreshControl *uiRefreshControl;
@property (nonatomic, strong) MyEventsRequest *myEventsRequest;

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation InvitedEventsTableViewController
#pragma mark - instantiation
/**
 * Lazily instantiate the empty view
 */
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
        [_eventManager loadData];
    }
    return _eventManager;
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
/**
 * selector for refreshing
 */
-(void)refresh:(id)sender {
    [self.refreshButton setEnabled:false];
    //we check if there is a internet connection, if no then stop refreshing and alert
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        [[self myEventsRequest] refreshMyEvents];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        [self endRefresh];
    }
}

- (IBAction)doRefresh:(id)sender {
    [[self uiRefreshControl] beginRefreshing];
    [self refresh:[self uiRefreshControl]];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - [self uiRefreshControl].frame.size.height) animated:YES];
}

/**
 * Method that basically update the latest info to the table at the end of refreshing
 */
-(void)endRefresh {
    [[self eventManager] loadData];
    [self.tableView reloadData];
    [[self uiRefreshControl] endRefreshing];
    [self.refreshButton setEnabled:true];
}

#pragma mark - delegate for my events request
- (void)notifyMyEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self endRefresh];
}

- (void)notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    [self endRefresh];
}

#pragma mark - view delegate
//handle event when view first load
-(void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.tableView.nxEV_emptyView = [self emptyView];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self setRefreshControl:[self uiRefreshControl]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:false];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        self.navigationController.hidesBarsOnSwipe = YES;
        [self.navigationController.barHideOnSwipeGestureRecognizer addTarget:self action:@selector(swipe:)];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        [self.navigationController.barHideOnSwipeGestureRecognizer removeTarget:self action:@selector(swipe:)];
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2 animations:^{
        [UIApplication sharedApplication].statusBarHidden = (self.navigationController.navigationBar.frame.origin.y < 0);
    }];
}

#pragma mark - table view delegate
// Get the number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self eventManager] getNumberOfSections];
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self eventManager] getTitleForHeaderInSection:section];
}

// Customize the title
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 6, 300, 18);
    myLabel.font = [UIFont fontWithName:@"SourceSansPro-SemiBold" size:14];
    myLabel.textColor = [UIColor colorWithRed:23/255.0 green:23/255.0 blue:23/255.0 alpha:1.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    UIView *labelContainer = [[UIView alloc] init];
    labelContainer.frame = CGRectMake(0, 0, screenWidth, 30);
    labelContainer.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    [labelContainer addSubview:myLabel];
    
    UIView *topBorber = [[UIView alloc] init];
    topBorber.frame = CGRectMake(0, 0, screenWidth, 1);
    topBorber.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    
    UIView *bottomBorder = [[UIView alloc] init];
    bottomBorder.frame = CGRectMake(0, 30, screenWidth, 1);
    bottomBorder.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:labelContainer];
    if (section != 0) [headerView addSubview:topBorber];
    [headerView addSubview:bottomBorder];
    
    return headerView;
}

// Customize the height for the title
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 31;
}


// Get the number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self eventManager] getNumberOfRowsInSection:section];
}

// Get the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    Event *event = [[self eventManager] getEventAtIndexPath:indexPath];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:400];
    UILabel *eventName = (UILabel *)[cell viewWithTag:401];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:402];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:404];
    UIView *border = (UIView *)[cell viewWithTag:405];
    
    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;    
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    border.hidden = (indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1));

    return cell;
}

//delegate for when user select a certain row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    //we check if there is a internet connection, if no then stop refreshing and alert
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        Event *event = [[self eventManager] getEventAtIndexPath:indexPath];
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
