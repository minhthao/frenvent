//
//  FirstLoadingViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FirstLoadingViewController.h"
#import "FriendEventsRequest.h"
#import "MyEventsRequest.h"
#import "FriendsRequest.h"
#import "DbEventsRequest.h"
#import "DbUserRequest.h"
#import "EventCoreData.h"
#import "FriendCoreData.h"
#import "Constants.h"
#import "DBNotificationRequest.h"
#import "TimeSupport.h"

static NSInteger NUM_QUERIES = 4; //one for friends event, one for my events, one for friends, one for nearby
NSInteger numQueriesDone;
NSInteger numFriendsEvents;
NSInteger numMyEvents;

@interface FirstLoadingViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) FriendEventsRequest *friendEventsRequest;
@property (nonatomic, strong) MyEventsRequest *myEventsRequest;
@property (nonatomic, strong) FriendsRequest *friendsRequest;
@property (nonatomic, strong) DbEventsRequest *dbEventsRequest;
@property (nonatomic) BOOL friendListObtain;
@property (nonatomic) BOOL readyToNavigateToMainPage;

@property (nonatomic) BOOL pageControlIsChangingPage;

@property (nonatomic) BOOL didGetNearbyEvent;

@end

@implementation FirstLoadingViewController 

#pragma mark - initiation
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
 * Lazily instantiate the friendEventsRequest
 * @return FriendEventsRequest
 */
- (FriendEventsRequest *)friendEventsRequest{
    if (_friendEventsRequest == nil) {
        _friendEventsRequest = [[FriendEventsRequest alloc] init];
        _friendEventsRequest.delegate = self;
    }
    return _friendEventsRequest;
}

/**
 * Lazily instantiate myEventsRequest
 * @return MyEventsRequest
 */
- (MyEventsRequest *)myEventsRequest {
    if (_myEventsRequest == nil) {
        _myEventsRequest = [[MyEventsRequest alloc] init];
        _myEventsRequest.delegate = self;
    }
    return _myEventsRequest;
}

/**
 * Lazily instantiate friendsRequest
 * @return FriendsRequest
 */
- (FriendsRequest *)friendsRequest {
    if (_friendsRequest == nil) {
        _friendsRequest = [[FriendsRequest alloc] init];
        _friendsRequest.delegate = self;
    }
    return _friendsRequest;
}

/**
 * Lazily instantiate the db event requests
 * @return DbEventsRequest
 */
- (DbEventsRequest *)dbEventsRequest {
    if (_dbEventsRequest == nil) {
        _dbEventsRequest = [[DbEventsRequest alloc] init];
        _dbEventsRequest.delegate = self;
    }
    return _dbEventsRequest;
}

#pragma mark - delegates for fb request
//delegate for FriendEventsRequest
- (void) notifyFriendEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    numFriendsEvents = [allEvents count];
    [[self dbEventsRequest] uploadEvents:allEvents];
}

- (void) notifyFriendEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
    
}

//delegate for MyEventsRequest
- (void) notifyMyEventsQueryCompletedWithResult:(NSArray *)allEvents :(NSMutableDictionary *)newEvents {
    numMyEvents = 0;
    int64_t todayTime = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    for (Event *event in allEvents) {
        if ([event.startTime longLongValue] >= todayTime) numMyEvents++;
    }
    
    [[self dbEventsRequest] uploadEvents:allEvents];
}

-(void) notifyMyEventsQueryEncounterError:(void (^)(UIBackgroundFetchResult))completionHandler {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

//delegate for FriendsRequest
- (void) notifyFriendsQueryCompleted {
    numQueriesDone ++;
    self.friendListObtain = true;
    if (!self.loadingView.isHidden) [self showFriendSelectionView];
}

- (void) notifyFriendsQueryError {
    numQueriesDone ++;
    self.friendListObtain = true;
    if (!self.loadingView.isHidden) [self showSecondLoginView];
}

#pragma mark - delegate for server requests
//upload request
- (void) notifyEventsUploaded {
    numQueriesDone++;
    [self checkIfAllQueryCompleted];
}

- (void) notifyNearbyEventsInitialized {
    numQueriesDone++;
    [self checkIfAllQueryCompleted];
}

- (void) notifyEventRequestFailure {
    numQueriesDone++;
    [self checkIfAllQueryCompleted];
}

//delegate for DBNotificationRequest
- (void) notifyNotificationComplete {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [defaults stringForKey:FB_LOGIN_USER_ID];
    NSString *name = [defaults stringForKey:FB_LOGIN_USER_NAME];
    
    [defaults setBool:true forKey:LOGIN_DATA_INITIALIZED];
    [defaults synchronize];
    
    DbUserRequest *userRequest = [[DbUserRequest alloc] init];
    [userRequest registerUser:uid :name :numFriendsEvents :numMyEvents];
    [self performSegueWithIdentifier:@"mainViewWithInitialize" sender:Nil];
}

//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    if (locations != nil && [locations count] > 0 && !self.didGetNearbyEvent) {
        self.didGetNearbyEvent = true;
        CLLocation *currentLocation = [locations objectAtIndex:0];
        [[self dbEventsRequest] initNearbyEvents:(double)[currentLocation coordinate].longitude :(double)[currentLocation coordinate].latitude];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

#pragma mark - view controller delegate

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    
    //setup the view
    self.friendListObtain = false;
    self.readyToNavigateToMainPage = false;
    self.loadingView.hidden = true;
    
    [self initTutorialView];
    
    self.friendSelectionView.hidden = true;
    self.secondLoginView.hidden = true;
    
    //start requests
    self.didGetNearbyEvent = false;
    numQueriesDone = 0;
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        [[self locationManager] startUpdatingLocation];
    else numQueriesDone++;
    
    [[self friendsRequest] initFriends];
    [[self friendEventsRequest] initFriendEvents];
    [[self myEventsRequest] initMyEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pageControlIsChangingPage) return;
    self.pageControl.currentPage = [self getCurrentPage:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControlIsChangingPage = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.pageControlIsChangingPage = NO;
}

#pragma mark - change the page in the scroll view
- (void)changePage:(UIPageControl *)sender {
    CGRect frame = self.tutorialView.frame;
    frame.origin.x = self.tutorialView.frame.size.width * [self pageControl].currentPage;
    frame.origin.y = 0;
    frame.size = self.tutorialView.frame.size;
    [self.tutorialScrollView scrollRectToVisible:frame animated:YES];
    self.pageControlIsChangingPage = YES;
}

- (int)getCurrentPage:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    //switch page at 50% across
    return floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)changeToPage:(int)page {
    CGRect frame = self.tutorialView.frame;
    self.pageControl.currentPage = page;
    frame.origin.x = self.tutorialView.frame.size.width * [self pageControl].currentPage;
    frame.origin.y = 0;
    frame.size = self.tutorialView.frame.size;
    [self.tutorialScrollView scrollRectToVisible:frame animated:NO];
    self.pageControlIsChangingPage = YES;
}

-(void)showFriendSelectionView {
    self.tutorialView.hidden = true;
    if (self.friendListObtain) {
        self.loadingView.hidden = true;
        self.friendSelectionView.hidden = false;
    } else {
        self.loadingView.hidden = false;
    }
}

-(void)showSecondLoginView {
    self.loadingView.hidden = true;
    self.friendSelectionView.hidden = true;
    self.secondLoginView.hidden = false;
}

#pragma mark - initiate the views
-(void)initTutorialView {
    self.tutorialView.hidden = false;
    [self initPageControl];
    
    CGSize tutorialFrame = self.tutorialView.frame.size;
    self.tutorialScrollView.contentSize = CGSizeMake(tutorialFrame.width * 5, tutorialFrame.height);
    
    UIImageView *view1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tutorialFrame.width, tutorialFrame.height)];
    if (tutorialFrame.height > 540) [view1 setImage:[UIImage imageNamed:@"TutorialFirstPageIphone5"]]; //iphone5
    else [view1 setImage:[UIImage imageNamed:@"TutorialFirstPageIphone4"]];
    [self.tutorialScrollView addSubview:view1];
    
    UIImageView *view2 = [[UIImageView alloc] initWithFrame:CGRectMake(tutorialFrame.width, 0, tutorialFrame.width, tutorialFrame.height)];
    if (tutorialFrame.height > 540) [view2 setImage:[UIImage imageNamed:@"TutorialSecondPageIphone5"]];
    else [view2 setImage:[UIImage imageNamed:@"TutorialSecondPageIphone4"]];
    [self.tutorialScrollView addSubview:view2];
    
    UIImageView *view3 = [[UIImageView alloc] initWithFrame:CGRectMake(tutorialFrame.width * 2, 0, tutorialFrame.width, tutorialFrame.height)];
    if (tutorialFrame.height > 540) [view3 setImage:[UIImage imageNamed:@"TutorialThirdPageIphone5"]];
    else [view3 setImage:[UIImage imageNamed:@"TutorialThirdPageIphone4"]];
    [self.tutorialScrollView addSubview:view3];
    
    UIImageView *view4 = [[UIImageView alloc] initWithFrame:CGRectMake(tutorialFrame.width * 3, 0, tutorialFrame.width, tutorialFrame.height)];
    if (tutorialFrame.height >  540) [view4 setImage:[UIImage imageNamed:@"TutorialFourthPageIphone5"]];
    else [view4 setImage:[UIImage imageNamed:@"TutorialFourthPageIphone4"]];
    [self.tutorialScrollView addSubview:view4];
    
    UIView *view5 = [[UIView alloc] initWithFrame:CGRectMake(tutorialFrame.width * 4, 0, tutorialFrame.width, tutorialFrame.height)];
    UIImageView *view5Image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tutorialFrame.width, tutorialFrame.height)];
    if (tutorialFrame.height > 540) [view5Image setImage:[UIImage imageNamed:@"TutorialFifthPageIphone5"]];
    else [view5Image setImage:[UIImage imageNamed:@"TutorialFifthPageIphone4"]];
    [view5 addSubview:view5Image];
    
    
    UIButton *goToFriendSelectionViewButton = [[UIButton alloc] initWithFrame:CGRectMake((tutorialFrame.width - 50)/2, tutorialFrame.height - 90, 50, 30)];
    [goToFriendSelectionViewButton setTitle:@"Next" forState:UIControlStateNormal];
    [goToFriendSelectionViewButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
    [goToFriendSelectionViewButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [goToFriendSelectionViewButton setBackgroundColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0]];
    [goToFriendSelectionViewButton.layer setCornerRadius:3.0f];
    [goToFriendSelectionViewButton.layer setMasksToBounds:YES];
    [goToFriendSelectionViewButton.layer setBorderWidth:0.5f];
    [goToFriendSelectionViewButton.layer setBorderColor:[[UIColor colorWithRed:40/255.0 green:70/255.0 blue:135/255.0 alpha:1.0] CGColor]];
    [goToFriendSelectionViewButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [goToFriendSelectionViewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goToFriendSelectionViewButton addTarget:self action:@selector(showFriendSelectionView) forControlEvents:UIControlEventTouchUpInside];
    [view5 addSubview:goToFriendSelectionViewButton];
    
    [self.tutorialScrollView addSubview:view5];
}

-(void)initFriendSelectionView {
    self.friendSelectionView.hidden = true;
    
}

-(void)initSecondLoginView {
    self.secondLoginView.hidden = true;
}

-(void)initPageControl {
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.numberOfPages = 5;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - private methods
/**
 * Check if all tasks are completed. If so, then segue to the main view
 */
- (void) checkIfAllQueryCompleted {
    
    if (numQueriesDone == NUM_QUERIES && self.readyToNavigateToMainPage) {
        DBNotificationRequest *notificationRequest = [[DBNotificationRequest alloc] init];
        notificationRequest.delegate = self;
        [notificationRequest getNotifications];
    }
}

- (IBAction)doneAction:(id)sender {
    self.readyToNavigateToMainPage = true;
    self.secondLoginView.hidden = true;
    self.loadingView.hidden = false;
    [self checkIfAllQueryCompleted];
}

- (IBAction)nextActionFromSelectionView:(id)sender {
    //TODO, check if the checkbox is done then make changes
    [self showSecondLoginView];
}

@end
