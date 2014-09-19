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
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FriendManager.h"
#import "UITableView+NXEmptyView.h"
#import "MyColor.h"
#import "ToastView.h"

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
@property (nonatomic) BOOL didGetNearbyEvent;
@property (nonatomic) BOOL pageControlIsChangingPage;

@property (nonatomic) UIButton *skipToFriendSelectionButton;

@property (nonatomic, strong) UIWebView *secondLoginWebView;
@property (nonatomic, strong) UILabel *loginErrorLabel;

@property (nonatomic, strong) FriendManager *friendManager;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) NSArray *allFriends;

@property (nonatomic, strong) NSMutableSet *selectedFriends;

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

/**
 * Lazily instantiate the second login webview
 * @return second login webview
 */
- (UIWebView *)secondLoginWebView {
    if (_secondLoginWebView == nil) {
        float screenHeight = [[UIScreen mainScreen] bounds].size.height;
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        if (screenHeight > 540) _secondLoginWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 368, screenWidth, 200/screenWidth * 320)];
        else _secondLoginWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 280, screenWidth, 200)];
        [_secondLoginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://m.facebook.com"]]];
        [_secondLoginWebView.scrollView setContentInset:UIEdgeInsetsMake(-114, 0, 0, 0)];
        [_secondLoginWebView.scrollView setScrollEnabled:false];
        _secondLoginWebView.scrollView.delegate = self;
        _secondLoginWebView.delegate = self;
    }
    return _secondLoginWebView;
}

/** 
 * Lazily instantiate the login error message
 * @return login error message
 */
- (UILabel *)loginErrorLabel {
    if (_loginErrorLabel == nil) {
        float screenHeight = [[UIScreen mainScreen] bounds].size.height;
        if (screenHeight > 540) _loginErrorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 350, 290, 18)];
        else _loginErrorLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 262, 270, 18)];
        _loginErrorLabel.text = @"* Error: Incorrect username or password";
        _loginErrorLabel.textColor = [UIColor redColor];
        _loginErrorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.5];
        //_loginErrorLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _loginErrorLabel;
}

-(UIView *)emptyView {
    if (_emptyView == nil) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.friendSelectionView.frame.size.height)];
        _emptyView.backgroundColor = [MyColor eventCellButtonNormalBackgroundColor];
        
        UILabel *noResult = [[UILabel alloc] initWithFrame:CGRectMake(0, self.friendSelectionView.frame.size.height/2 - 50, 320, 36)];
        noResult.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
        noResult.textColor = [MyColor eventCellButtonsContainerBorderColor];
        noResult.shadowColor = [UIColor whiteColor];
        noResult.textAlignment = NSTextAlignmentCenter;
        noResult.shadowOffset = CGSizeMake(1, 1);
        noResult.text = @"No matches";
        [_emptyView addSubview:noResult];
    }
    return _emptyView;
}

- (FriendManager *)friendManager {
    if (_friendManager == nil) _friendManager = [[FriendManager alloc] init];
    return _friendManager;
}

- (NSMutableSet *)selectedFriends {
    if (_selectedFriends == nil) _selectedFriends = [[NSMutableSet alloc] init];
    return _selectedFriends;
}

#pragma mark - webview delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *currentUrl = webView.request.URL.absoluteString;
    if ([currentUrl rangeOfString:@"m.facebook.com/home.php?"].location != NSNotFound) {
        [[self secondLoginWebView] removeFromSuperview];
        _secondLoginWebView = nil;
        _loginErrorLabel = nil;
        [self navigateToMainPage];
    } else if (![currentUrl isEqualToString:@"https://m.facebook.com/"]) {
        [self loginErrorLabel].hidden = false;
        [[self secondLoginWebView] goBack];
    }
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
    self.allFriends = [FriendCoreData getAllFriends];
    [[self friendManager] setFriends:self.allFriends];
    [self.friendSelectionTableView reloadData];
    if (!self.loadingView.isHidden) [self showFriendSelectionView:nil];
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
    [self performSelector:@selector(goToMainView) withObject:nil afterDelay:0.5];
}

//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    if (locations != nil && [locations count] > 0 && !self.didGetNearbyEvent) {
        self.didGetNearbyEvent = true;
        CLLocation *currentLocation = [locations objectAtIndex:0];
        [[self dbEventsRequest] initNearbyEvents:(double)[currentLocation coordinate].longitude :(double)[currentLocation coordinate].latitude];
    } else if (!self.didGetNearbyEvent){
        numQueriesDone ++;
        [self checkIfAllQueryCompleted];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    numQueriesDone ++;
    [self checkIfAllQueryCompleted];
}

#pragma mark- keyboard delegate
- (void)keyboardWillShow: (NSNotification *) notif{
    CGRect secondLoginWebViewFrame = self.secondLoginView.frame;
    self.secondLoginView.frame = CGRectMake(secondLoginWebViewFrame.origin.x, secondLoginWebViewFrame.origin.y - 260, secondLoginWebViewFrame.size.width, secondLoginWebViewFrame.size.height);
}

- (void)keyboardWillHide: (NSNotification *) notif{
    CGRect secondLoginWebViewFrame = self.secondLoginView.frame;
    self.secondLoginView.frame = CGRectMake(secondLoginWebViewFrame.origin.x, secondLoginWebViewFrame.origin.y + 260, secondLoginWebViewFrame.size.width, secondLoginWebViewFrame.size.height);
}

#pragma mark - view controller delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendSelectionTableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.friendSelectionTableView.nxEV_emptyView = [self emptyView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    
    //setup the view
    self.friendListObtain = false;
    self.readyToNavigateToMainPage = false;
    self.loadingView.hidden = true;
    
    [self initTutorialView];
    [self initFriendSelectionView];
    [self initSecondLoginView];
    
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
    if (scrollView != self.friendSelectionTableView) {
        if (scrollView != self.tutorialScrollView) {
            CGRect webViewBound = [self secondLoginWebView].bounds;
            scrollView.bounds = CGRectMake(0, 114, webViewBound.size.width, webViewBound.size.height);
        } else if (self.skipToFriendSelectionButton != nil){
            if ([self getCurrentPage:scrollView] == 4)
                [self.skipToFriendSelectionButton setTitle:@"Done" forState:UIControlStateNormal];
            else [self.skipToFriendSelectionButton setTitle:@"Skip" forState:UIControlStateNormal];
            
            if (self.pageControlIsChangingPage) return;
            self.pageControl.currentPage = [self getCurrentPage:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControlIsChangingPage = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.pageControlIsChangingPage = NO;
}

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

#pragma mark - selector for navigating within the view
-(void)showFriendSelectionView:(UIButton *)sender {
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
    
    for (Friend *friend in self.allFriends) {
        if (self.selectAllButton.selected || [[self selectedFriends] containsObject:friend.uid])
            [FriendCoreData setFriend:friend toFavorite:true];
    }
}

- (void)navigateToMainPage {
    self.readyToNavigateToMainPage = true;
    self.secondLoginView.hidden = true;
    self.loadingView.hidden = false;
    [self checkIfAllQueryCompleted];
}

- (void)goToMainView {
    [self performSegueWithIdentifier:@"mainViewWithInitialize" sender:Nil];
}

#pragma mark - initiate the views
-(void)initTutorialView {
    self.tutorialView.hidden = false;
    [self initPageControl];
    
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    self.tutorialView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    if (screenHeight > 540) self.skipToFriendSelectionButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 65, 18, 50, 36)];
    else self.skipToFriendSelectionButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 65, 431, 50, 36)];
    [self.skipToFriendSelectionButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipToFriendSelectionButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.5]];
    [self.skipToFriendSelectionButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.skipToFriendSelectionButton setTitleColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.skipToFriendSelectionButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [self.skipToFriendSelectionButton addTarget:self action:@selector(showFriendSelectionView:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize tutorialFrame = self.tutorialView.frame.size;
    [self.tutorialView addSubview:self.skipToFriendSelectionButton];
    
    self.tutorialScrollView.contentSize = CGSizeMake(tutorialFrame.width * 5, tutorialFrame.height);
    
    // first tutorial view
    UIImageView *view1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tutorialFrame.width, tutorialFrame.height)];
    [view1 setContentMode:UIViewContentModeScaleAspectFill];
    if (screenHeight > 540) {
        if (screenWidth == 320) [view1 setImage:[UIImage imageNamed:@"TutorialFirstPageIphone5"]]; //iphone5
        else if (screenWidth == 375) [view1 setImage:[UIImage imageNamed:@"TutorialFirstPageIphone6"]]; //iphone6
        else [view1 setImage:[UIImage imageNamed:@"TutorialFirstPageIphone6Plus"]]; //iphone6Plus
    } else [view1 setImage:[UIImage imageNamed:@"TutorialFirstPageIphone4"]];
    [self.tutorialScrollView addSubview:view1];
    
    // second tutorial view
    UIImageView *view2 = [[UIImageView alloc] initWithFrame:CGRectMake(tutorialFrame.width, 0, tutorialFrame.width, tutorialFrame.height)];
    [view2 setContentMode:UIViewContentModeScaleAspectFill];
    if (screenHeight > 540) {
        if (screenWidth == 320) [view2 setImage:[UIImage imageNamed:@"TutorialSecondPageIphone5"]];
        else if (screenWidth == 375) [view2 setImage:[UIImage imageNamed:@"TutorialSecondPageIphone6"]];
        else [view2 setImage:[UIImage imageNamed:@"TutorialSecondPageIphone6Plus"]]; //iphone6Plus
    } else [view2 setImage:[UIImage imageNamed:@"TutorialSecondPageIphone4"]];
    [self.tutorialScrollView addSubview:view2];
    
    //third tutorial view
    UIImageView *view3 = [[UIImageView alloc] initWithFrame:CGRectMake(tutorialFrame.width * 2, 0, tutorialFrame.width, tutorialFrame.height)];
    [view3 setContentMode:UIViewContentModeScaleAspectFill];
    if (screenHeight > 540) {
        if (screenWidth == 320) [view3 setImage:[UIImage imageNamed:@"TutorialThirdPageIphone5"]];
        else if (screenWidth == 375) [view3 setImage:[UIImage imageNamed:@"TutorialThirdPageIphone6"]];
        else [view3 setImage:[UIImage imageNamed:@"TutorialThirdPageIphone6Plus"]]; //iphone6Plus
    } else [view3 setImage:[UIImage imageNamed:@"TutorialThirdPageIphone4"]];
    [self.tutorialScrollView addSubview:view3];
    
    //fourth tutorial view
    UIImageView *view4 = [[UIImageView alloc] initWithFrame:CGRectMake(tutorialFrame.width * 3, 0, tutorialFrame.width, tutorialFrame.height)];
    [view4 setContentMode:UIViewContentModeScaleAspectFill];
    if (screenHeight > 540) {
        if (screenWidth == 320) [view4 setImage:[UIImage imageNamed:@"TutorialFourthPageIphone5"]];
        else if (screenWidth == 375) [view4 setImage:[UIImage imageNamed:@"TutorialFourthPageIphone6"]];
        else [view4 setImage:[UIImage imageNamed:@"TutorialFourthPageIphone6Plus"]]; //iphone6Plus
    } else [view4 setImage:[UIImage imageNamed:@"TutorialFourthPageIphone4"]];
    [self.tutorialScrollView addSubview:view4];
    
    //fifth tutorial view
    UIImageView *view5 = [[UIImageView alloc] initWithFrame:CGRectMake(tutorialFrame.width * 4, 0, tutorialFrame.width, tutorialFrame.height)];
    [view5 setContentMode:UIViewContentModeScaleAspectFill];
    if (screenHeight > 540) {
        if (screenWidth == 320) [view5 setImage:[UIImage imageNamed:@"TutorialFifthPageIphone5"]];
        else if (screenWidth == 375) [view5 setImage:[UIImage imageNamed:@"TutorialFifthPageIphone6"]];
        else [view5 setImage:[UIImage imageNamed:@"TutorialFifthPageIphone6Plus"]]; //iphone6Plus
    } else [view5 setImage:[UIImage imageNamed:@"TutorialFifthPageIphone4"]];
    [self.tutorialScrollView addSubview:view5];
}

-(void)initFriendSelectionView {
    self.friendSelectionView.hidden = true;
    self.selectAllButton.selected = true;
    self.friendSelectionNextButton.enabled = true;
    
    self.searchBar.backgroundImage = [MyColor imageWithColor:[UIColor colorWithRed:236/255.0 green:239/255.0 blue:242/255.0 alpha:1]];
}

-(void)initSecondLoginView {
    self.secondLoginView.hidden = true;
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 65, 18, 50, 36)];
    [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [skipButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.5]];
    [skipButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [skipButton setTitleColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [skipButton addTarget:self action:@selector(navigateToMainPage) forControlEvents:UIControlEventTouchUpInside];
    [self.secondLoginView addSubview:skipButton];
    
    [self.secondLoginView addSubview:[self secondLoginWebView]];
    [self.secondLoginView addSubview:[self loginErrorLabel]];
    [self loginErrorLabel].hidden = true;
    
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    UIImageView *profileImage;
    UILabel *profileName;
    UILabel *description;

    if (screenHeight > 540) {
        profileImage = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - 86)/2, 82, 86, 86)];
        profileName = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, screenWidth, 28)];
        description = [[UILabel alloc] initWithFrame:CGRectMake(20, 240, screenWidth - 40, 50)];
    } else {
        profileImage = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - 86)/2, 65, 86, 86)];
        profileName = [[UILabel alloc] initWithFrame:CGRectMake(0, 152, screenWidth, 28)];
        description = [[UILabel alloc] initWithFrame:CGRectMake(20, 190, screenWidth - 40, 50)];
    }
    
    [profileImage.layer setCornerRadius:15.0f];
    [profileImage.layer setMasksToBounds:YES];
    [profileImage.layer setBorderWidth:2];
    [profileImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [profileName setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    [profileName setTextAlignment:NSTextAlignmentCenter];
    [profileName setTextColor:[UIColor colorWithRed:46/255.0 green:46/255.0 blue:46/255.0 alpha:1.0]];
    
    [description setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.5]];
    [description setTextAlignment:NSTextAlignmentCenter];
    [description setTextColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0]];
    [description setNumberOfLines:0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [defaults stringForKey:FB_LOGIN_USER_ID];
    NSString *name = [defaults stringForKey:FB_LOGIN_USER_NAME];
    NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=150&height=150", uid];
    
    [profileImage setImageWithURL:[NSURL URLWithString:url]];
    profileName.text = name;
    description.text = @"Frenvent has some features that may require additional certificates from Facebook. Please log-in one more time.";
    
    [self.secondLoginView addSubview:profileImage];
    [self.secondLoginView addSubview:profileName];
    [self.secondLoginView addSubview:description];
}

-(void)initPageControl {
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.numberOfPages = 5;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Table view data source

//Get the number of seccion in table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self friendManager].sectionTitles count];
}

//Get the title for the header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self friendManager].sectionTitles objectAtIndex:section];
}

//get the number of items in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:section];
    NSMutableArray *sectionEvents = [[self friendManager] getSectionedFriendsList:sectionTitle];
    return [sectionEvents count];
}

//Get the index title for index searching
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self friendManager] getCharacterIndices];
}

//Get the index of the title
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self friendManager].sectionTitles indexOfObject:title];
}

//Display the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendItem"];
    
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
    Friend *friend = [sectionFriends objectAtIndex:indexPath.row];
    
    if ([[self selectedFriends] containsObject:friend.uid])
        [tableView selectRowAtIndexPath:indexPath animated:true scrollPosition:UITableViewScrollPositionNone];
    else [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    UIImageView *profilePicture = (UIImageView *)[cell viewWithTag:101];
    UILabel *username = (UILabel *)[cell viewWithTag:102];
    
    NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", friend.uid];
    [profilePicture setImageWithURL:[NSURL URLWithString:url]];
    username.text = friend.name;
    
    return cell;
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectAllButton.selected = false;
    
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
    Friend *friend = [sectionFriends objectAtIndex:indexPath.row];
    
    if (![[self selectedFriends] containsObject:friend.uid]) {
        [[self selectedFriends] addObject:friend.uid];
        
        if ([[self selectedFriends] count] >= 10) self.friendSelectionNextButton.enabled = true;
        else {
            [ToastView showToastOnTopOfParentView:self.friendSelectionView withText:[NSString stringWithFormat:@"Select %d more", (int)(10 - [[self selectedFriends] count])] withDuaration:1.5f];
            self.friendSelectionNextButton.enabled = false;
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectAllButton.selected = false;
    
    NSString *sectionTitle = [[self friendManager].sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionFriends = [[self friendManager] getSectionedFriendsList:sectionTitle];
    Friend *friend = [sectionFriends objectAtIndex:indexPath.row];
    if ([[self selectedFriends] containsObject:friend.uid]) {
        [[self selectedFriends] removeObject:friend.uid];
        if ([[self selectedFriends] count] < 10)
            [ToastView showToastOnTopOfParentView:self.friendSelectionView withText:[NSString stringWithFormat:@"Select %d more", (int)(10 - [[self selectedFriends] count])] withDuaration:1.5];
    }
}

#pragma mark - search bar delegate
//handle the case where the new item is typed in the search
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        NSArray *searchResults = [self.allFriends filteredArrayUsingPredicate:resultPredicate];
        [[self friendManager] setFriends:searchResults];
    } else [[self friendManager] setFriends:self.allFriends];
    
    [self.friendSelectionTableView reloadData];
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



- (IBAction)nextActionFromSelectionView:(id)sender {
    //TODO, check if the checkbox is done then make changes
    [self showSecondLoginView];
}

- (IBAction)selectAllFriendsAction:(id)sender {
    if (self.selectAllButton.selected) {
        self.selectAllButton.selected = false;
        if ([[self selectedFriends] count] >= 20) self.friendSelectionNextButton.enabled = true;
        else self.friendSelectionNextButton.enabled = false;
    } else {
        self.selectAllButton.selected = true;
        self.friendSelectionNextButton.enabled = true;
    }
}

@end
