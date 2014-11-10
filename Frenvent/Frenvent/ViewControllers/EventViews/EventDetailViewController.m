//
//  EventDetailViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "EventDetailViewController.h"
#import "EventDetailsRequest.h"
#import "UIImageView+AFNetworking.h"
#import "Event.h"
#import "EventDetail.h"
#import "EventCoreData.h"
#import "DbEventsRequest.h"
#import "EventRsvpRequest.h"
#import "MyColor.h"
#import "ToastView.h"
#import "ShareEventRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "WebViewController.h"
#import "WebViewUser.h"
#import "EventWebViewController.h"
#import "EventParticipantView.h"
#import "FbUserInfoViewController.h"
#import "EventDetailRecommendUserRequest.h"

static NSInteger const ACTION_SHEET_RSVP_ATTENDING = 1;
static NSInteger const ACTION_SHEET_RSVP_MAYBE = 2;
static NSInteger const ACTION_SHEET_RSVP_NOT_REPLIED = 3;
static NSInteger const ACTION_SHEET_RSVP_DEFAULT = 4;
static NSInteger const ACTION_SHEET_SHARE_EVENT = 5;
static NSInteger const ACTION_SHEET_NAVIGATION = 6;

@interface EventDetailViewController ()

@property (nonatomic, strong) EventDetailsRequest *eventDetailsRequest;
@property (nonatomic, strong) EventDetail *eventDetail;
@property (nonatomic, strong) DbEventsRequest *dbEventsRequest;

@property (nonatomic, strong) EventDetailRecommendUserRequest *eventDetailRecommendUserRequest;
@property (nonatomic, strong) NSArray *recommendFriends;

@property (nonatomic, strong) UIActionSheet *rsvpActionSheetWithCurrentRsvpAttending;
@property (nonatomic, strong) UIActionSheet *rsvpActionSheetWithCurrentRsvpMaybe;
@property (nonatomic, strong) UIActionSheet *rsvpActionSheetWithCurrentRsvpNotReplied;
@property (nonatomic, strong) UIActionSheet *rsvpActionSheetDefault;
@property (nonatomic, strong) UIActionSheet *shareActionSheet;
@property (nonatomic, strong) UIActionSheet *navigationSheet;

@property (nonatomic, strong) EventRsvpRequest *eventRsvpRequest;
@property (nonatomic, strong) ShareEventRequest *shareEventRequest;

@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) PagedUserScrollView *usersScrollView;
@property (nonatomic, strong) NSMutableArray *quoteArrays;

@end

@implementation EventDetailViewController

#pragma mark - initiation
/**
 * Lazily instantiate the event detail request
 * @return event detail request
 */
- (EventDetailsRequest *)eventDetailsRequest {
    if (_eventDetailsRequest == nil) {
        _eventDetailsRequest = [[EventDetailsRequest alloc] init];
        _eventDetailsRequest.delegate = self;
    }
    return _eventDetailsRequest;
}

/**
 * Lazily instantiate the db event request
 * @return DbEventsRequest
 */
- (DbEventsRequest *)dbEventsRequest {
    if (_dbEventsRequest == nil) _dbEventsRequest = [[DbEventsRequest alloc] init];
    return _dbEventsRequest;
}

/**
 * Lazily instantiate the event detail recommend user reuqest
 * @return EventDetailRecommendUserRequest
 */
- (EventDetailRecommendUserRequest *)eventDetailRecommendUserRequest {
    if (_eventDetailRecommendUserRequest == nil) {
        _eventDetailRecommendUserRequest = [[EventDetailRecommendUserRequest alloc] init];
        _eventDetailRecommendUserRequest.delegate = self;
    }
    return _eventDetailRecommendUserRequest;
}

/**
 * Lazily instantiate the rsvp action sheet when current rsvp status is attending
 * @return rsvp action sheet
 */
- (UIActionSheet *)rsvpActionSheetWithCurrentRsvpAttending {
    if (_rsvpActionSheetWithCurrentRsvpAttending == nil) {
        _rsvpActionSheetWithCurrentRsvpAttending = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Maybe", @"Not going", nil];
        _rsvpActionSheetWithCurrentRsvpAttending.tag = ACTION_SHEET_RSVP_ATTENDING;
    }
    return _rsvpActionSheetWithCurrentRsvpAttending;
}

/**
 * Lazily instantiate the rsvp action sheet when current rsvp status is unsure
 * @return rsvp action sheet
 */
- (UIActionSheet *)rsvpActionSheetWithCurrentRsvpMaybe {
    if (_rsvpActionSheetWithCurrentRsvpMaybe == nil) {
        _rsvpActionSheetWithCurrentRsvpMaybe = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Going", @"Not going", nil];
        _rsvpActionSheetWithCurrentRsvpMaybe.tag = ACTION_SHEET_RSVP_MAYBE;
    }
    return _rsvpActionSheetWithCurrentRsvpMaybe;
}

/**
 * Lazily instantiate the rsvp action sheet when current rsvp status is attending
 * @return rsvp action sheet
 */
- (UIActionSheet *)rsvpActionSheetWithCurrentRsvpNotReplied {
    if (_rsvpActionSheetWithCurrentRsvpNotReplied == nil) {
        _rsvpActionSheetWithCurrentRsvpNotReplied = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Going", @"Maybe", @"Not going", nil];
        _rsvpActionSheetWithCurrentRsvpNotReplied.tag = ACTION_SHEET_RSVP_NOT_REPLIED;
    }
    return _rsvpActionSheetWithCurrentRsvpNotReplied;
}

/**
 * Lazily instantiate the rsvp action sheet when current rsvp status is attending
 * @return rsvp action sheet
 */
- (UIActionSheet *)rsvpActionSheetDefault {
    if (_rsvpActionSheetDefault == nil) {
        _rsvpActionSheetDefault = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Going", @"Maybe", nil];
        _rsvpActionSheetDefault.tag = ACTION_SHEET_RSVP_DEFAULT;
    }
    return _rsvpActionSheetDefault;
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
        _shareActionSheet.tag = ACTION_SHEET_SHARE_EVENT;
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
 * Lazily instantiate the navigation action sheet
 * @return navigation action sheet
 */
-(UIActionSheet *)navigationSheet {
    if (_navigationSheet == nil) {
        _navigationSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Get direction", nil];
        _navigationSheet.tag = ACTION_SHEET_NAVIGATION;
    }
    return _navigationSheet;
}

/**
 * Lazily instantiate the join button
 * @return UIButton
 */
-(UIButton *)joinButton {
    if (_joinButton == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _joinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth * 0.33, 75)];
        [_joinButton setImage:[UIImage imageNamed:@"EventDetailJoinButton"] forState:UIControlStateNormal];
        [_joinButton setImage:[UIImage imageNamed:@"EventDetailJoinButtonSelected"] forState:UIControlStateSelected];
        [_joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _joinButton;
}

/**
 * Lazily instantiate the save button
 * @return UIButton
 */
-(UIButton *)saveButton {
    if (_saveButton == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth * 0.335, 0, screenWidth * 0.33, 75)];
        [_saveButton setImage:[UIImage imageNamed:@"EventDetailSaveButton"] forState:UIControlStateNormal];
        [_saveButton setImage:[UIImage imageNamed:@"EventDetailSaveButtonSelected"] forState:UIControlStateSelected];
        [_saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

/**
 * Lazily instantiate the more button
 * @return UIButton
 */
-(UIButton *)moreButton {
    if (_moreButton == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth * 0.67, 0, screenWidth * 0.33, 75)];
        [_moreButton setImage:[UIImage imageNamed:@"EventDetailAboutButton"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

//init the paged user scroll view
- (PagedUserScrollView *)usersScrollView {
    if (_usersScrollView == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGRect scrollViewFrame = CGRectMake(17, 0, screenWidth - 34, (screenWidth - 40) * (240/280.0));
        
        _usersScrollView = [[PagedUserScrollView alloc] initWithFrame:scrollViewFrame];
        _usersScrollView.delegate = self;
    }
    return _usersScrollView;
}

//init the quote array
- (NSMutableArray *)quoteArrays {
    if (_quoteArrays == nil) {
        _quoteArrays = [[NSMutableArray alloc] init];
        [_quoteArrays addObject:@"“Hey that bubble chat icon looks like a perfect ice breaker, don’t you think?”"];
        [_quoteArrays addObject:@"“You’re not gonna wait for me to add you, right?”"];
    }
    return _quoteArrays;
}

#pragma mark - UIActionSheet, back click, and alertview delegate
/**
 * delegate for the action sheet
 */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.eventDetail != nil) {
        if (actionSheet.tag == ACTION_SHEET_RSVP_ATTENDING) {
            switch (buttonIndex) {
                case 0:
                    [[self eventRsvpRequest] replyUnsureToEvent:self.eventDetail.eid];
                    break;
                case 1:
                    [[self eventRsvpRequest] replyDeclineToEvent:self.eventDetail.eid];
                    break;
                default:
                    break;
            }
        } else if (actionSheet.tag == ACTION_SHEET_RSVP_MAYBE){
            switch (buttonIndex) {
                case 0:
                    [[self eventRsvpRequest] replyAttendingToEvent:self.eventDetail.eid];
                    break;
                case 1:
                    [[self eventRsvpRequest] replyDeclineToEvent:self.eventDetail.eid];
                    break;
                default:
                    break;
            }
        } else if (actionSheet.tag == ACTION_SHEET_RSVP_NOT_REPLIED) {
            switch (buttonIndex) {
                case 0:
                    [[self eventRsvpRequest] replyAttendingToEvent:self.eventDetail.eid];
                    break;
                case 1:
                    [[self eventRsvpRequest] replyUnsureToEvent:self.eventDetail.eid];
                    break;
                case 2:
                    [[self eventRsvpRequest] replyDeclineToEvent:self.eventDetail.eid];
                    break;
                default:
                    break;
            }
        } else if (actionSheet.tag == ACTION_SHEET_RSVP_DEFAULT) {
            switch (buttonIndex) {
                case 0:
                    [[self eventRsvpRequest] replyAttendingToEvent:self.eventDetail.eid];
                    break;
                case 1:
                    [[self eventRsvpRequest] replyUnsureToEvent:self.eventDetail.eid];
                    break;
                default:
                    break;
            }
        } else if (actionSheet.tag == ACTION_SHEET_SHARE_EVENT) {
            switch (buttonIndex) {
                case 0:
                    [[self shareEventRequest] shareToFriendTheEventWithEid:self.eventDetail.eid];
                    break;
                case 1:
                    [[self shareEventRequest] shareToWallTheEvent:self.eventDetail.eid];
                    break;
                default:
                    break;

            }
        } else if (actionSheet.tag == ACTION_SHEET_NAVIGATION) {
            if (buttonIndex == 0) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.eventDetail.latitude, self.eventDetail.longitude);
                MKPlacemark* destPlace = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil] ;
                MKMapItem* destMapItem = [[MKMapItem alloc] initWithPlacemark:destPlace] ;
                destMapItem.name = self.eventDetail.name;
                
                NSArray* mapItems = [[NSArray alloc] initWithObjects: destMapItem, nil];
                NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys: MKLaunchOptionsDirectionsModeDriving,
                                         MKLaunchOptionsDirectionsModeKey, nil];
                [MKMapItem openMapsWithItems:mapItems launchOptions:options];
            }
        }
    }
}

/**
 * Delegate for the alert view. Happen when the queried failed to get the event detail. Force close the view
 */
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:true];
}

/**
 * Back click delegate, call when the back click button is pressed for the case from applink
 */
-(void)backClick {
    [self dismissViewControllerAnimated:true completion:NULL];
}

#pragma mark - requests delegates
/**
 * Delegate for event rsvp
 * @param success state
 * @param current rsvp
 */
-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvp {
    if (success) {
        self.eventDetail.rsvp = rsvp;
        [self.mainView reloadData];
        [ToastView showToastInParentView:self.view withText:@"Event successfully RSVP" withDuaration:3.0];
    } else [ToastView showToastInParentView:self.view withText:@"Fail to RSVP event" withDuaration:3.0];
}

/**
 * Delegate to notify that shae event request have been completed
 * @param boolean
 */
-(void)notifyShareEventRequestSuccess:(BOOL)success {
    if (success) [ToastView showToastInParentView:self.view withText:@"Event shared successfully" withDuaration:3.0];
    else [ToastView showToastInParentView:self.view withText:@"Fail to share event" withDuaration:3.0];
}

#pragma mark - delegate for request
/**
 * If the event did not exist, remove it from our local database and exist
 */
- (void)notifyEventDidNotExist {
    [self.loadingSpinner stopAnimating];
    [EventCoreData removeEventWithEid:self.eid];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Event no longer exist."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

/**
 * If the query for event fail fail, simply exist
 */
- (void)notifyEventDetailsQueryFail {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Error getting event information."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

/**
 * Notify that event query have been completed successfull and with the result
 * @param event detail
 */
- (void)notifyEventDetailsQueryCompletedWithResult:(EventDetail *)eventDetail {
    [eventDetail addToCoreData];
    Event *event = [EventCoreData getEventWithEid:eventDetail.eid];
    [[self dbEventsRequest] uploadEvents:@[event]];
    self.shareButton.enabled = [event canShare];
    
    self.eventDetail = eventDetail;
    self.title = eventDetail.name;
    [self showTopView:eventDetail];
    [self.mainView reloadData];
    
    [self.loadingSpinner stopAnimating];
}

/**
 * Notify that query for recommended people is completed with a set of result
 * @param array of suggest friends
 */
-(void)notifyEventDetailRecommendUserCompleteWithResult:(NSArray *)suggestFriends {
    self.recommendFriends = suggestFriends;
    [self.mainView reloadData];
}

/**
 * Notify that query for recommended people has failed
 */
-(void)notifyEventDetailRecommendUserQueryFail {
    //do nothing
}

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.shareButton setEnabled:false];
    
    [[self eventDetailsRequest] queryEventDetail:self.eid];
    [[self eventDetailRecommendUserRequest] queryRecommendUser:self.eid];
    
    if (self.isModal) self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.headerView.frame = CGRectMake(0, 0, screenWidth, 120);
    
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
    [UIApplication sharedApplication].statusBarHidden = (self.navigationController.navigationBar.frame.origin.y < 0);
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"webView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        WebViewController *viewController = segue.destinationViewController;
        WebViewUser *webViewUser = (WebViewUser *)sender;
        viewController.url = webViewUser.url;
        viewController.uid = webViewUser.uid;
        viewController.name = webViewUser.name;
    } else if ([[segue identifier] isEqualToString:@"eventWebView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        EventWebViewController *viewController = segue.destinationViewController;
        if (sender) {
            viewController.url = [NSString stringWithFormat:@"https://m.facebook.com/events/%@", self.eventDetail.eid];
            viewController.eid = self.eventDetail.eid;
        } else {
            viewController.url = [NSString stringWithFormat:@"https://m.facebook.com/events/%@/permalink/guests/?filter=friends", self.eventDetail.eid];
        }
    } else if ([[segue identifier] isEqualToString:@"friendInfoView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        NSString *uid = (NSString *)sender;
        FbUserInfoViewController *viewController = segue.destinationViewController;
        viewController.targetUid = uid;
    }
}


#pragma mark - handle item click
/**
 * Delegate for share button
 */
- (IBAction)shareAction:(id)sender {
    if ([FBDialogs canPresentMessageDialog])
        [[self shareActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    else [[self shareEventRequest] shareToWallTheEvent:self.eventDetail.eid];
}

/**
 * delegate for the join button
 */
- (void)joinButtonClick:(id)sender {
    [[self joinButton] setHighlighted:true];
    
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        if ([self.eventDetail.rsvp isEqualToString:RSVP_ATTENDING])
            [[self rsvpActionSheetWithCurrentRsvpAttending] showInView:[UIApplication sharedApplication].keyWindow];
        else if ([self.eventDetail.rsvp isEqualToString:RSVP_UNSURE])
            [[self rsvpActionSheetWithCurrentRsvpMaybe] showInView:[UIApplication sharedApplication].keyWindow];
        else if ([self.eventDetail.rsvp isEqualToString:RSVP_NOT_REPLIED])
            [[self rsvpActionSheetWithCurrentRsvpNotReplied] showInView:[UIApplication sharedApplication].keyWindow];
        else [[self rsvpActionSheetDefault] showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

/**
 * Delegate for save button
 */
- (void)saveButtonClick:(id)sender {
    Event *event = [EventCoreData getEventWithEid:self.eventDetail.eid];
    if ([event.markType intValue] == MARK_TYPE_FAVORITE) {
        [EventCoreData setEventMarkType:event withType:MARK_TYPE_NORMAL];
        [[self saveButton] setSelected:false];
        [ToastView showToastInParentView:self.view withText:@"Removed event from your calendar" withDuaration:3.0];
    } else {
        [EventCoreData setEventMarkType:event withType:MARK_TYPE_FAVORITE];
        [[self saveButton] setSelected:true];
        [ToastView showToastInParentView:self.view withText:@"Event added to your calendar" withDuaration:3.0];
    }
    [self.mainView reloadData];
}

/**
 * delegate for more button
 */
- (void)moreButtonClick:(id)sender {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        [self performSegueWithIdentifier:@"eventWebView" sender:[NSNumber numberWithBool:true]];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

/**
 * delegate for participant click
 */
-(void)participantClick:(NSString *)uid {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        [self performSegueWithIdentifier:@"friendInfoView" sender:uid];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

-(void)handleMembersContainerTap:(UITapGestureRecognizer *)recognizer {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        [self performSegueWithIdentifier:@"eventWebView" sender:nil];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

-(void)handleLocationButtonTap:(UIGestureRecognizer *)recogizer {
    if (self.eventDetail.longitude != 0 && self.eventDetail.latitude != 0) {
        [[self navigationSheet] showInView:[UIApplication sharedApplication].keyWindow];
    } else [ToastView showToastInParentView:self.view withText:@"Cannot identify the event location" withDuaration:3.0];
}

#pragma mark - other view related function
/**
 * show the header view as soon as the query for the event detail is done
 * @param event detail
 */
-(void)showTopView:(EventDetail *)eventDetail {
    //get the cover
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIImageView *cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 120)];
    cover.contentMode = UIViewContentModeScaleAspectFill;
    cover.clipsToBounds = true;
    if ([eventDetail.cover length] > 0) [cover setImageWithURL:[NSURL URLWithString:eventDetail.cover]];
    else [cover setImage:[MyColor imageWithColor:[UIColor lightGrayColor]]];
    
    //format the title
    UILabel *eventName = [[UILabel alloc] init];
    eventName.text = eventDetail.name;
    eventName.font = [UIFont fontWithName:@"SourceSansPro-Semibold" size:16];
    eventName.textColor = [UIColor whiteColor];
    eventName.numberOfLines = 2;
    float viewHeight = [eventName sizeThatFits:CGSizeMake(screenWidth - 70, FLT_MAX)].height;
    eventName.frame = CGRectMake(20, 105 - viewHeight, screenWidth - 70, viewHeight);
    
    //adding overlay
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 90 - viewHeight, screenWidth, viewHeight + 30);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.75] CGColor], nil];
    [cover.layer insertSublayer:gradient atIndex:0];
    
    //add all the components to view
    [self.headerView addSubview:cover];
    [self.headerView addSubview:eventName];
}

#pragma mark - table view delegates
//number of sections in table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.eventDetail == nil) return 0;
    else return 1;
}

//number of row in section. If recommended users are found, then 3. Otherwise, it will be 2
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 1;
    if (self.recommendFriends != nil && [self.recommendFriends count] > 0) numRows++;
    if ([self.eventDetail.eDescription length] > 0) numRows++;
    return numRows;
}

// customized header view
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *buttonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 75)];
    buttonsContainer.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [buttonsContainer.layer setMasksToBounds:NO];
    [buttonsContainer.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [buttonsContainer.layer setShadowRadius:2];
    [buttonsContainer.layer setShadowOffset:CGSizeMake(0, 2)];
    [buttonsContainer.layer setShadowOpacity:0.15f];
    
    Event *event = [EventCoreData getEventWithEid:self.eventDetail.eid];
    [self saveButton].selected = ([event.markType intValue] == MARK_TYPE_FAVORITE);
    
    [self joinButton].enabled = [event canRsvp];
    [self joinButton].selected = ([event.rsvp isEqualToString:RSVP_ATTENDING] || [event.rsvp isEqualToString:RSVP_UNSURE]);
    
    [buttonsContainer addSubview:[self joinButton]];
    [buttonsContainer addSubview:[self saveButton]];
    [buttonsContainer addSubview:[self moreButton]];

    [headerView addSubview:buttonsContainer];
    return headerView;
}

// Customize the height for the title
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

//cell for table view
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (self.recommendFriends != nil && [self.recommendFriends count] > 0)
            return [self recommendUsersViewCell:tableView cellForRowAtIndexPath:indexPath];
        else return [self infoViewCell:tableView cellForRowAtIndexPath:indexPath];
    } else if (indexPath.row == 1) {
        if (self.recommendFriends != nil && [self.recommendFriends count] > 0)
            return [self infoViewCell:tableView cellForRowAtIndexPath:indexPath];
        else return [self descriptionViewCell:tableView cellForRowAtIndexPath:indexPath];
    } else return [self descriptionViewCell:tableView cellForRowAtIndexPath:indexPath];
}

//height for each view cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat infoHeight = 114;
    if ([self.eventDetail.location length] > 0) infoHeight += 44;
    if ([self.eventDetail.attendingFriends count] > 0) infoHeight += 85;
    
    UITextView *tempView = [[UITextView alloc] init];
    tempView.text = self.eventDetail.eDescription;
    tempView.textContainer.lineFragmentPadding = 0;
    tempView.textContainerInset = UIEdgeInsetsZero;
    tempView.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:14];
    
    CGSize textViewSize = [tempView sizeThatFits:CGSizeMake([[UIScreen mainScreen] bounds].size.width - 50, FLT_MAX)];
    CGFloat descriptionHeight = textViewSize.height + 72;

    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat recommendHeight = 15 + 10 + 18 + 10 + (screenWidth - 40) * (240/280.0) + 59;
    
    if (indexPath.row == 0) {
        if (self.recommendFriends != nil && [self.recommendFriends count] > 0) return recommendHeight;
        else return infoHeight;
    } else if (indexPath.row == 1) {
        if (self.recommendFriends != nil && [self.recommendFriends count] > 0) return infoHeight;
        else return descriptionHeight;
    } else return descriptionHeight;
    
}

#pragma mark - table view cells
/**
 * Table view cell for the recommend users
 * @param tableView
 * @param indexpath
 * @return table cell
 */
-(UITableViewCell *)recommendUsersViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recommendUsersView" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recommendUsersView"];
    
    
    UIView *containerView = (UIView *)[cell viewWithTag:1];
    [containerView.layer setCornerRadius:4.0f];
    [containerView.layer setMasksToBounds:NO];
    [containerView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [containerView.layer setShadowRadius:2.5];
    [containerView.layer setShadowOffset:CGSizeMake(0, 2)];
    [containerView.layer setShadowOpacity:0.15f];
    
    UIView *scrollView = (UIView *)[cell viewWithTag:3];
    for (UIView *subview in [[self usersScrollView] subviews]) {
        [subview removeFromSuperview];
    }
    
    [[self usersScrollView] setSuggestedUsers:self.recommendFriends];
    [scrollView addSubview:[self usersScrollView]];
    
    UILabel *quoteLabel = (UILabel *)[cell viewWithTag:4];
    quoteLabel.text = [self pickupQuote];
    return cell;
}

/**
 * Table view cell for the info view
 * @param tableView
 * @param indexpath
 * @return table cell
 */
-(UITableViewCell *)infoViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoViewCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"infoViewCell"];
    
    UIView *containerView = (UIView *)[cell viewWithTag:1];
    [containerView.layer setCornerRadius:4.0f];
    [containerView.layer setMasksToBounds:NO];
    [containerView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [containerView.layer setShadowRadius:2.5];
    [containerView.layer setShadowOffset:CGSizeMake(0, 2)];
    [containerView.layer setShadowOpacity:0.15f];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat currentHeight = 0;
    
    //adding the location
    if ([self.eventDetail.location length] > 0) {
        UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 20, 44)];
        
        //adding the image
        UIImageView *locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 15, 15)];
        locationIcon.image = [UIImage imageNamed:@"EventDetailLocationIcon"];
        [locationView addSubview:locationIcon];
        
        //adding the location text
        UILabel *locationText = [[UILabel alloc] initWithFrame:CGRectMake(45, 14, screenWidth - 85, 18)];
        locationText.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:14];
        locationText.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
        locationText.text = self.eventDetail.location;
        [locationView addSubview:locationText];
        
        //adding the separator
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 43, screenWidth - 20, 1)];
        separator.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        [locationView addSubview:separator];
        
        UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLocationButtonTap:)];
        [locationView addGestureRecognizer:locationTap];
        
        [containerView addSubview:locationView];
        currentHeight += 44;
    }
    
    //adding the time
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, screenWidth - 20, 44)];
    timeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *timeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveButtonClick:)];
    [timeView addGestureRecognizer:timeTap];
    
    UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 15, 15)];
    timeIcon.image = [UIImage imageNamed:@"EventDetailTimeIcon"];
    [timeView addSubview:timeIcon];
    
    UILabel *timeText = [[UILabel alloc] initWithFrame:CGRectMake(45, 14, screenWidth - 85, 18)];
    timeText.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:14];
    timeText.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    timeText.text = [self.eventDetail getEventDisplayTime];
    [timeView addSubview:timeText];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 43, screenWidth - 20, 1)];
    separator.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    [timeView addSubview:separator];
    
    [containerView addSubview:timeView];
    currentHeight += 44;
    
    //adding the attended friends
    if ([self.eventDetail.attendingFriends count] > 0) {
        UIView *attendingFriendsView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, screenWidth - 20, 85)];

        //add the scroll view for attending friends
        UIScrollView *friendsAttendingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 8, screenWidth - 40, 50)];
        [friendsAttendingScrollView setContentSize:CGSizeMake(55 * [self.eventDetail.attendingFriends count] - 5, 50)];
        
        for (int i = 0; i < [self.eventDetail.attendingFriends count]; i++) {
            EventParticipantView *participantView = [[EventParticipantView alloc] initWithFrame:CGRectMake(55 * i, 0, 50, 50)];
            participantView.delegate = self;
            [participantView setEventPartipant:[self.eventDetail.attendingFriends objectAtIndex:i]];
            [friendsAttendingScrollView addSubview:participantView];
        }
        [attendingFriendsView addSubview:friendsAttendingScrollView];
        
        //add the text of friend attendings and member
        UILabel *friendsAttending = [[UILabel alloc] initWithFrame:CGRectMake(10, 63, containerView.frame.size.width - 20, 18)];
        friendsAttending.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
        friendsAttending.numberOfLines = 1;
        friendsAttending.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:14];
        friendsAttending.attributedText = [self.eventDetail getFriendsInterested];
        [attendingFriendsView addSubview:friendsAttending];
        
        //add the line separator
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 84, screenWidth - 20, 1)];
        separator.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        [attendingFriendsView addSubview:separator];
        
        [containerView addSubview:attendingFriendsView];
        currentHeight += 85;
    }
    
    //finally we added in the number of people interested
    UIView *interestedNumberView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, screenWidth - 20, 60)];
    UITapGestureRecognizer *interestedNumberViewTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMembersContainerTap:)];
    [interestedNumberView addGestureRecognizer:interestedNumberViewTap];
    CGFloat labelWidth = (screenWidth - 20)/3;
    
    //add the view for number of going
    UIView *joinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelWidth, 60)];
    UILabel *joinNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, labelWidth, 22)];
    joinNumber.text = [NSString stringWithFormat:@"%d", self.eventDetail.attendingCount];
    joinNumber.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:18];
    joinNumber.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    joinNumber.textAlignment = NSTextAlignmentCenter;
    [joinView addSubview:joinNumber];
    
    UILabel *joinText = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, labelWidth, 13)];
    joinText.text = @"Going";
    joinText.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:10];
    joinText.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    joinText.textAlignment = NSTextAlignmentCenter;
    [joinView addSubview:joinText];
    
    [interestedNumberView addSubview:joinView];
    
    //add the view for the number of maybe
    UIView *maybeView = [[UIView alloc] initWithFrame:CGRectMake(labelWidth, 0, labelWidth, 60)];
    UILabel *maybeNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, labelWidth, 22)];
    maybeNumber.text = [NSString stringWithFormat:@"%d", self.eventDetail.unsureCount];
    maybeNumber.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:18];
    maybeNumber.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    maybeNumber.textAlignment = NSTextAlignmentCenter;
    [maybeView addSubview:maybeNumber];
    
    UILabel *maybeText = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, labelWidth, 13)];
    maybeText.text = @"Maybe";
    maybeText.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:10];
    maybeText.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    maybeText.textAlignment = NSTextAlignmentCenter;
    [maybeView addSubview:maybeText];
    
    [interestedNumberView addSubview:maybeView];
    
    //add the view for the number of invited
    UIView *invitedView = [[UIView alloc] initWithFrame:CGRectMake(labelWidth * 2, 0, labelWidth, 60)];
    UILabel *invitedNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, labelWidth, 22)];
    invitedNumber.text = [NSString stringWithFormat:@"%d", self.eventDetail.unrepliedCount];
    invitedNumber.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:18];
    invitedNumber.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    invitedNumber.textAlignment = NSTextAlignmentCenter;
    [invitedView addSubview:invitedNumber];
    
    UILabel *invitedText = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, labelWidth, 13)];
    invitedText.text = @"Maybe";
    invitedText.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:10];
    invitedText.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    invitedText.textAlignment = NSTextAlignmentCenter;
    [invitedView addSubview:invitedText];
    
    [interestedNumberView addSubview:invitedView];
    
    [containerView addSubview:interestedNumberView];
    
    return cell;
}

/**
 * Table view cell for the description view
 * @param tableView
 * @param indexpath
 * @return table cell
 */
-(UITableViewCell *)descriptionViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionViewCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descriptionViewCell"];
    
    UIView *containerView = (UIView *)[cell viewWithTag:1];
    [containerView.layer setCornerRadius:4.0f];
    [containerView.layer setMasksToBounds:NO];
    [containerView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [containerView.layer setShadowRadius:2.5];
    [containerView.layer setShadowOffset:CGSizeMake(0, 2)];
    [containerView.layer setShadowOpacity:0.15f];
    
    UITextView *description = (UITextView *)[cell viewWithTag:2];
    description.textContainer.lineFragmentPadding = 0;
    description.textContainerInset = UIEdgeInsetsZero;
    description.text = self.eventDetail.eDescription;
    description.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    description.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:14];
    description.scrollsToTop = false;
    
    return cell;
}

#pragma mark - others and delegates
/**
 * Delegate for when the suggested friends scroll view scroll from one view to another
 * @param scroll view
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == [self usersScrollView]) {
        NSIndexPath *recommendUsersIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.mainView cellForRowAtIndexPath:recommendUsersIndexPath];
        UILabel *quoteLabel = (UILabel *)[cell viewWithTag:4];
        
        [UIView transitionWithView:quoteLabel duration:.5f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
            quoteLabel.text = [self pickupQuote];
        } completion:nil];
    }
}

/**
 * A simple function that will returned a random pick up quote
 * @return NSString
 */
-(NSString *)pickupQuote {
    return (NSString *)[[self quoteArrays] objectAtIndex:(rand() % [[self quoteArrays] count])];
}

/**
 * Handle the case when any of the suggested friends is clicked
 * @param suggest friend
 */
-(void)userClicked:(SuggestFriend *)suggestedUser {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        WebViewUser *webViewUser = [[WebViewUser alloc] init];
        webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", suggestedUser.uid];
        webViewUser.uid = suggestedUser.uid;
        webViewUser.name = suggestedUser.name;
        [self performSegueWithIdentifier:@"webView" sender:webViewUser];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

/**
 * Handle the case when the say hi button is clicked
 * @param suggest friend
 */
-(void)hiButtonClicked:(SuggestFriend *)suggestedUser {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        WebViewUser *webViewUser = [[WebViewUser alloc] init];
        webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/messages/compose?ids=%@", suggestedUser.uid];
        webViewUser.uid = suggestedUser.uid;
        webViewUser.name = suggestedUser.name;
        [self performSegueWithIdentifier:@"webView" sender:webViewUser];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet and try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}


@end