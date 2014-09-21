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
@property (nonatomic, strong) NSString *rsvpToChangeTo;

@property (nonatomic, strong) ShareEventRequest *shareEventRequest;

@property (nonatomic, strong) UIImageView *cover;
@property (nonatomic, strong) UILabel *eventTitle;
@property (nonatomic, strong) UILabel *rsvpStatus;
@property (nonatomic, strong) UILabel *startTime;

@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *moreButton;

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
    if (_dbEventsRequest == nil) {
        _dbEventsRequest = [[DbEventsRequest alloc] init];
        _dbEventsRequest.delegate = self;
    }
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
 * Lazily instantiate the cover 
 * @return cover
 */
-(UIImageView *)cover {
    if (_cover == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 150)];
        _cover.contentMode = UIViewContentModeScaleAspectFill;
        _cover.clipsToBounds = true;
        if ([self.eventDetail.cover length] > 0)
            [_cover setImageWithURL:[NSURL URLWithString:self.eventDetail.cover]];
        else [_cover setImage:[MyColor imageWithColor:[UIColor darkGrayColor]]];

        [self.headerView addSubview:_cover];
    }
    return _cover;
}

/**
 * Lazily instantiate the event title
 * @return event title lable
 */
-(UILabel *)eventTitle {
    if (_eventTitle == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        
        _eventTitle = [[UILabel alloc] init];
        _eventTitle.text = self.eventDetail.name;
        _eventTitle.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
        _eventTitle.textColor = [UIColor whiteColor];
        _eventTitle.shadowColor = [UIColor blackColor];
        _eventTitle.shadowOffset = CGSizeMake(1, 1);
        _eventTitle.numberOfLines = 3;
        
        float viewHeight = [_eventTitle sizeThatFits:CGSizeMake(screenWidth - 8, FLT_MAX)].height;
        _eventTitle.frame = CGRectMake(8, 122 - viewHeight, screenWidth - 16, viewHeight);
        
        [self.headerView addSubview:_eventTitle];
    }
    return _eventTitle;
}

/**
 * Lazily instantiate the event rsvp and privacy
 * @return privacy and rsvp status
 */
-(UILabel *)rsvpStatus {
    if (_rsvpStatus == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _rsvpStatus = [[UILabel alloc] initWithFrame:CGRectMake(8, 124 , screenWidth - 16, 21)];
        _rsvpStatus.text = [self.eventDetail getDisplayPrivacyAndRsvp];
        _rsvpStatus.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
        _rsvpStatus.textColor = [UIColor whiteColor];
        _rsvpStatus.shadowColor = [UIColor darkGrayColor];
        _rsvpStatus.shadowOffset = CGSizeMake(0, 1);
        [self.headerView addSubview:_rsvpStatus];
    }
    return _rsvpStatus;
}

/**
 * Lazily instantiate the join button
 * @return UIButton
 */
-(UIButton *)joinButton {
    if (_joinButton == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _joinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth * 0.33, 50)];
        _joinButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        [_joinButton setTitle:@"Join" forState:UIControlStateNormal];
        [_joinButton setImage:[UIImage imageNamed:@"EventDetailJoinButton"] forState:UIControlStateNormal];
        [_joinButton setImage:[UIImage imageNamed:@"EventDetailJoinButtonSelected"] forState:UIControlStateSelected];
        [_joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self formatMenuButton:_joinButton];
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
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth * 0.335, 0, screenWidth * 0.33, 50)];
        _saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [_saveButton setImage:[UIImage imageNamed:@"EventDetailSaveButton"] forState:UIControlStateNormal];
        [_saveButton setImage:[UIImage imageNamed:@"EventDetailSaveButtonSelected"] forState:UIControlStateSelected];
        [_saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self formatMenuButton:_saveButton];
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
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth * 0.67, 0, screenWidth * 0.33, 50)];
        _moreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        [_moreButton setTitle:@"More" forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"EventDetailAboutButton"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self formatMenuButton:_moreButton];
    }
    return _moreButton;
}

/**
 * Lazily instantiate the start time label
 * @return UILabel
 */
-(UILabel *)startTime {
    if (_startTime == nil) {
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        _startTime = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, screenWidth - 70, 45)];
        _startTime.numberOfLines = 2;
        _startTime.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5];
        _startTime.textColor = [UIColor darkGrayColor];
    }
    return _startTime;
}

//@property (nonatomic, strong) UILabel *startTime;


#pragma mark - UIActionSheet and rsvp delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.eventDetail != nil) {
        if (actionSheet.tag == ACTION_SHEET_RSVP_ATTENDING) {
            switch (buttonIndex) {
                case 0:
                    self.rsvpToChangeTo = RSVP_UNSURE;
                    [[self eventRsvpRequest] replyUnsureToEvent:self.eventDetail.eid];
                    break;
                case 1:
                    self.rsvpToChangeTo = RSVP_DECLINED;
                    [[self eventRsvpRequest] replyDeclineToEvent:self.eventDetail.eid];
                    break;
                default:
                    break;
            }
        } else if (actionSheet.tag == ACTION_SHEET_RSVP_MAYBE){
            switch (buttonIndex) {
                case 0:
                    self.rsvpToChangeTo = RSVP_ATTENDING;
                    [[self eventRsvpRequest] replyAttendingToEvent:self.eventDetail.eid];
                    break;
                    
                case 1:
                    self.rsvpToChangeTo = RSVP_DECLINED;
                    [[self eventRsvpRequest] replyDeclineToEvent:self.eventDetail.eid];
                    break;
                    
                default:
                    break;
            }
        } else if (actionSheet.tag == ACTION_SHEET_RSVP_NOT_REPLIED) {
            switch (buttonIndex) {
                case 0:
                    self.rsvpToChangeTo = RSVP_ATTENDING;
                    [[self eventRsvpRequest] replyAttendingToEvent:self.eventDetail.eid];
                    break;
                    
                case 1:
                    self.rsvpToChangeTo = RSVP_UNSURE;
                    [[self eventRsvpRequest] replyUnsureToEvent:self.eventDetail.eid];
                    break;

                case 2:
                    self.rsvpToChangeTo = RSVP_DECLINED;
                    [[self eventRsvpRequest] replyDeclineToEvent:self.eventDetail.eid];
                    break;
                    
                default:
                    break;
            }
        } else if (actionSheet.tag == ACTION_SHEET_RSVP_DEFAULT) {
            switch (buttonIndex) {
                case 0:
                    self.rsvpToChangeTo = RSVP_ATTENDING;
                    [[self eventRsvpRequest] replyAttendingToEvent:self.eventDetail.eid];
                    break;
                    
                case 1:
                    self.rsvpToChangeTo = RSVP_UNSURE;
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

-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvp {
    if (success) {
        self.eventDetail.rsvp = self.rsvpToChangeTo;
        self.rsvpStatus.text = [self.eventDetail getDisplayPrivacyAndRsvp];
        [self refreshJoinButtonView];
        [ToastView showToastInParentView:self.view withText:@"Event successfully RSVP" withDuaration:3.0];
    } else [ToastView showToastInParentView:self.view withText:@"Fail to RSVP event" withDuaration:3.0];
}

-(void)notifyShareEventRequestSuccess:(BOOL)success {
    if (success) [ToastView showToastInParentView:self.view withText:@"Event shared successfully" withDuaration:3.0];
    else [ToastView showToastInParentView:self.view withText:@"Fail to share event" withDuaration:3.0];
}


-(void)notifyEventRequestFailure {
    //do nothing when you fail to upload the event
}


#pragma mark - delegate for request
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

- (void)notifyEventDetailsQueryFail {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Error getting event information."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

- (void)notifyEventDetailsQueryCompletedWithResult:(EventDetail *)eventDetail {
    self.eventDetail = eventDetail;
    
    [eventDetail addToCoreData];
    Event *event = [EventCoreData getEventWithEid:eventDetail.eid];
    [[self dbEventsRequest] uploadEvents:@[event]];
    
    if (![event canRsvp]) [[self joinButton] setEnabled:false];
    [self refreshJoinButtonView];
    if ([[event markType] intValue] == MARK_TYPE_FAVORITE) [[self saveButton] setSelected:true];
    else [[self saveButton] setSelected:false];
    
    if ([event canShare]) [self.shareButton setEnabled:true];
    
    self.title = eventDetail.name;
    [self cover];
    [self rsvpStatus];
    [self eventTitle];
    
    [self startTime].text = [eventDetail getEventDisplayTime];
    
    [self.loadingSpinner stopAnimating];
    [self.mainView setHidden:false];
    [self.mainView reloadData];
}

-(void)notifyEventsUploaded {
    //lets just do nothing for now
}

-(void)notifyEventDetailRecommendUserQueryFail {
}

-(void)notifyEventDetailRecommendUserCompleteWithResult:(NSArray *)suggestFriends {
    self.recommendFriends = suggestFriends;
    [self reloadTableData];
}

/**
 * Ask the main view to reload the data
 */
-(void)reloadTableData {
    if (self.recommendFriends == nil) [self performSelector:@selector(reloadTableData) withObject:nil afterDelay:0.2];
    else {
        //if ([self.recommendFriends count] > 0)[[self userScrollView] setSuggestedUsers:self.recommendFriends];
        [self.mainView reloadData];
    }
}

#pragma mark - alert view
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:true];
}

-(void)backClick {
    [self dismissViewControllerAnimated:true completion:NULL];
}

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.shareButton setEnabled:false];
    
    if (self.eid != nil) {
        [[self eventDetailsRequest] queryEventDetail:self.eid];
        [[self eventDetailRecommendUserRequest] queryRecommendUser:self.eid];
    }
    
    if (self.isModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    }
    
    [self.loadingSpinner setHidesWhenStopped:true];
    [self.loadingSpinner startAnimating];
    [self.mainView setHidden:true];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController isNavigationBarHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:false];
    }
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    self.headerView.frame = CGRectMake(0, 0, screenWidth, 245);
    
    UIView *buttonViews = [[UIView alloc] initWithFrame:CGRectMake(0, 150 , screenWidth, 50)];
    NSArray *separatorColor = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[MyColor eventCellButtonsContainerBorderColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = buttonViews.bounds;
    gradient.colors = separatorColor;
    [buttonViews.layer insertSublayer:gradient atIndex:0];
    
    [buttonViews addSubview:[self joinButton]];
    [buttonViews addSubview:[self saveButton]];
    [buttonViews addSubview:[self moreButton]];
    [self.headerView addSubview:buttonViews];
    
    UIView *timeViews = [[UIView alloc] initWithFrame:CGRectMake(0, 200, screenWidth, 45)];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    separator.backgroundColor = [UIColor lightGrayColor];
    [timeViews addSubview:separator];
    UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
    timeIcon.contentMode = UIViewContentModeScaleAspectFill;
    timeIcon.image = [UIImage imageNamed:@"EventDetailTimeIcon"];
    [timeViews addSubview:timeIcon];
    [timeViews addSubview:[self startTime]];
    [self.headerView addSubview:timeViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - handle item click
- (IBAction)shareAction:(id)sender {
    if ([FBDialogs canPresentMessageDialog])
        [[self shareActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    else [[self shareEventRequest] shareToWallTheEvent:self.eventDetail.eid];
}

- (IBAction)joinButtonClick:(id)sender {
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
        [self refreshJoinButtonView];
    }
}

- (IBAction)saveButtonClick:(id)sender {
    Event *event = [EventCoreData getEventWithEid:self.eventDetail.eid];
    if ([event.markType intValue] == MARK_TYPE_FAVORITE) {
        [EventCoreData setEventMarkType:event withType:MARK_TYPE_NORMAL];
        [[self saveButton] setSelected:false];
    } else {
        [EventCoreData setEventMarkType:event withType:MARK_TYPE_FAVORITE];
        [[self saveButton] setSelected:true];
    }
}

- (IBAction)moreButtonClick:(id)sender {
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
    }
}

-(void)userClicked:(SuggestFriend *)suggestedUser {
    WebViewUser *webViewUser = [[WebViewUser alloc] init];
    webViewUser.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", suggestedUser.uid];
    webViewUser.uid = suggestedUser.uid;
    webViewUser.name = suggestedUser.name;
    [self performSegueWithIdentifier:@"webView" sender:webViewUser];
}

#pragma mark - handle button state so that what it display is correct
- (void)refreshJoinButtonView {
    if ([self.eventDetail.rsvp isEqualToString:RSVP_ATTENDING] || [self.eventDetail.rsvp isEqualToString:RSVP_UNSURE])
        [[self joinButton] setSelected:true];
    else {
        [[self joinButton] setSelected:false];
        [[self joinButton] setHighlighted:false];
    }
}

-(void)formatMenuButton:(UIButton *)button {
    [button setTitleColor:[UIColor colorWithRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1.0] forState:UIControlStateDisabled];
    
    [button setImageEdgeInsets:UIEdgeInsetsMake(-14, 31, 0, 0)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(25, -26, 0, 0)];
    
    NSArray *buttonsColor = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0] CGColor], nil];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = button.bounds;
    gradient.colors = buttonsColor;
    [button.layer insertSublayer:gradient atIndex:0];
    [button bringSubviewToFront:button.imageView];
}

#pragma mark - table view delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.eventDetail != nil) {
        if ([self.eventDetail.eDescription length] > 0) return 2;
        else return 1;
    }
    else return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.eventDetail != nil) {
        if (section == 0) {
            NSInteger numRow = 1;
            if ([self.eventDetail.location length] > 0) numRow++;
            if ([self.recommendFriends count] > 0) numRow++;
            return numRow;
        } else return 1;
    } else return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.section == 0) {
        if ([self.eventDetail.location length] > 0) {
            if (indexPath.row == 0) {
                return [self getLocationTableViewCell:tableView withIndexPath:indexPath];
            } else if (indexPath.row == 1) {
                if ([self.eventDetail.attendingFriends count] > 0)
                    return [self getEventMembersWithFriendTableViewCell:tableView withIndexPath:indexPath];
                else return [self getEventMembersWithoutFriendTableViewCell:tableView withIndexPath:indexPath];
            } else return [self getEventRecommendUserTableViewCell:tableView withIndexPath:indexPath];
        } else {
            if (indexPath.row == 0) {
                if ([self.eventDetail.attendingFriends count] > 0)
                    return [self getEventMembersWithFriendTableViewCell:tableView withIndexPath:indexPath];
                else return [self getEventMembersWithoutFriendTableViewCell:tableView withIndexPath:indexPath];
            } else return [self getEventRecommendUserTableViewCell:tableView withIndexPath:indexPath];
        }
    } else return [self getEventDescriptionTableViewCell:tableView withIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([self.eventDetail.location length] > 0) {
            if (indexPath.row == 0) return 45;
            else if (indexPath.row == 1) {
                if ([self.eventDetail.attendingFriends count] > 0) return 155;
                else return 70;
            } else return 190;
        } else {
            if (indexPath.row == 0) {
                if ([self.eventDetail.attendingFriends count] > 0) return 155;
                else return 70;
            } else return 190;
        }
    } else return [self calculateDescriptionViewHeight];
}

-(CGFloat)calculateDescriptionViewHeight {
    UITextView *tempView = [[UITextView alloc] init];
    tempView.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    tempView.text = self.eventDetail.eDescription;
    
    CGSize textViewSize = [tempView sizeThatFits:CGSizeMake([[UIScreen mainScreen] bounds].size.width - 36, FLT_MAX)];
    return textViewSize.height + 15 + 5 + 15 + 5; //for padding, detail label pad, detail label, detail label bottom pad, and textview bottom pad
}

#pragma mark - get the table view cells
/**
 * Get and format the location table view cell
 * @param tableview
 * @param indexPath
 * @return UITableViewCell
 */
-(UITableViewCell *)getLocationTableViewCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventDetailLocationCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventDetailLocationCell"];
    
    for (UIView *subview in [cell.contentView subviews])
        [subview removeFromSuperview];
    
    UITapGestureRecognizer *navigationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLocationButtonTap:)];
    [cell.contentView setUserInteractionEnabled:true];
    [cell.contentView addGestureRecognizer:navigationTap];
    
    float screenWidth = cell.contentView.frame.size.width;
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    separator.backgroundColor = [MyColor eventCellButtonNormalBackgroundColor];
    [cell.contentView addSubview:separator];
    
    UIImageView *locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
    locationIcon.contentMode = UIViewContentModeScaleAspectFill;
    locationIcon.image = [UIImage imageNamed:@"EventDetailLocationIcon"];
    [cell.contentView addSubview:locationIcon];
    
    UILabel *locationLabel= [[UILabel alloc] initWithFrame:CGRectMake(55, 0, screenWidth - 70, 45)];
    locationLabel.text = self.eventDetail.location;
    locationLabel.numberOfLines = 2;
    locationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5];
    locationLabel.textColor = [UIColor darkGrayColor];
    [cell.contentView addSubview:locationLabel];
    
    return cell;
}

/**
 * Get and format the event member (with friends) table view cell
 * @param tableview
 * @param indexPath
 * @return UITableViewCell
 */
-(UITableViewCell *)getEventMembersWithFriendTableViewCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventDetailMemberCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventDetailMemberCell"];
    
    for (UIView *subview in [cell.contentView subviews]) {
        [subview removeFromSuperview];
    }
    
    //add the shadow to separate the top views
    float cellWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, 1)];
    NSArray *separatorColor = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[MyColor eventCellButtonNormalBackgroundColor] CGColor], nil];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = separator.bounds;
    gradient.colors = separatorColor;
    [separator.layer insertSublayer:gradient atIndex:0];
    [cell.contentView addSubview:separator];
    
    //mask the container to get the border and round corner
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(8, 10, cellWidth - 16, 140)];
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [cell.contentView addSubview:containerView];

    //add the list of friends interested
    UIView *friendsAttendingView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, containerView.frame.size.width - 20, 55)];
    
    CGFloat participantViewSize = friendsAttendingView.frame.size.height;
    UIScrollView *friendsAttendingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, friendsAttendingView.frame.size.width, participantViewSize)];
    [friendsAttendingView addSubview:friendsAttendingScrollView];
    [friendsAttendingScrollView setContentSize:CGSizeMake((participantViewSize + 5) * [self.eventDetail.attendingFriends count] - 5, participantViewSize)];

    for (int i = 0; i < [self.eventDetail.attendingFriends count]; i++) {
        CGRect participantFrame = CGRectMake((participantViewSize + 5) * i, 0, participantViewSize, participantViewSize);
        EventParticipantView *participantView = [[EventParticipantView alloc] initWithFrame:participantFrame];
        participantView.delegate = self;
        [participantView setEventPartipant:[self.eventDetail.attendingFriends objectAtIndex:i]];
        [friendsAttendingScrollView addSubview:participantView];
    }
    [containerView addSubview:friendsAttendingView];
    
    //display the text of friend attendings and member
    UILabel *friendsAttending = [[UILabel alloc] initWithFrame:CGRectMake(10, 62, containerView.frame.size.width - 20, 20)];
    friendsAttending.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];
    friendsAttending.numberOfLines = 1;
    friendsAttending.attributedText = [self.eventDetail getFriendsInterested];
    [containerView addSubview:friendsAttending];
    
    
    //Now we add the member container
    UIView *membersContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 85, containerView.frame.size.width, 55)];
    UITapGestureRecognizer *membersContainerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMembersContainerTap:)];
    [membersContainer setUserInteractionEnabled:true];
    [containerView addGestureRecognizer:membersContainerTap];
    
    UIView *memberSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, 1)];
    memberSeparator.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    [membersContainer addSubview:memberSeparator];
    
    [membersContainer addSubview:[self getNumMembersView:membersContainer.frame.size.width]];
    [containerView addSubview:membersContainer];
    
    return cell;
}

/**
 * Get the number of members view
 * @return UIView
 */
-(UIView *)getNumMembersView:(float)viewWidth {
    UIView *membersView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 55)];
    float width = viewWidth * 0.33;
    
    //join button
    UIView *joinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 55)];
    UILabel *numGoing = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, width, 21)];
    numGoing.text = [NSString stringWithFormat:@"%d", self.eventDetail.attendingCount];
    numGoing.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    numGoing.textColor = [UIColor darkGrayColor];
    numGoing.textAlignment = NSTextAlignmentCenter;
    [joinView addSubview:numGoing];
    
    UILabel *goingText = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, width, 15)];
    goingText.text = @"Going";
    goingText.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    goingText.textColor = [UIColor darkGrayColor];
    goingText.textAlignment = NSTextAlignmentCenter;
    [joinView addSubview:goingText];
    
    [membersView addSubview:joinView];
    
    UIView *firstSeparator = [[UIView alloc] initWithFrame:CGRectMake(width, 8, 1, 39)];
    firstSeparator.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    [membersView addSubview:firstSeparator];
    
    //maybe button
    UIView *maybeView = [[UIView alloc] initWithFrame:CGRectMake(0.335 * viewWidth, 0, width, 55)];
    UILabel *numMaybe = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, width, 21)];
    numMaybe.text = [NSString stringWithFormat:@"%d", self.eventDetail.unsureCount];
    numMaybe.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    numMaybe.textColor = [UIColor darkGrayColor];
    numMaybe.textAlignment = NSTextAlignmentCenter;
    [maybeView addSubview:numMaybe];
    
    UILabel *maybeText = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, width, 15)];
    maybeText.text = @"Maybe";
    maybeText.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    maybeText.textColor = [UIColor darkGrayColor];
    maybeText.textAlignment = NSTextAlignmentCenter;
    [maybeView addSubview:maybeText];
    
    [membersView addSubview:maybeView];
    
    UIView *secondSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.665 * viewWidth, 8, 1, 39)];
    secondSeparator.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    [membersView addSubview:secondSeparator];
    
    //invite button
    UIView *invitedView = [[UIView alloc] initWithFrame:CGRectMake(0.67 * viewWidth, 0, width, 55)];
    UILabel *numInvited = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, width, 21)];
    numInvited.text = [NSString stringWithFormat:@"%d", self.eventDetail.unrepliedCount];
    numInvited.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    numInvited.textColor = [UIColor darkGrayColor];
    numInvited.textAlignment = NSTextAlignmentCenter;
    [invitedView addSubview:numInvited];
    
    UILabel *invitedText = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, width, 15)];
    invitedText.text = @"Invited";
    invitedText.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    invitedText.textColor = [UIColor darkGrayColor];
    invitedText.textAlignment = NSTextAlignmentCenter;
    [invitedView addSubview:invitedText];
    
    [membersView addSubview:invitedView];
    
    return membersView;
}

/**
 * Get and format the event members (without friends) table view cell
 * @param tableview
 * @param indexPath
 * @return UITableViewCell
 */
-(UITableViewCell *)getEventMembersWithoutFriendTableViewCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventDetailMemberWithoutFriendCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventDetailMemberWithoutFriendCell"];
    
    for (UIView *subview in [cell.contentView subviews]) {
        [subview removeFromSuperview];
    }
    
    //add the shadow to separate the top views
    float cellWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, 1)];
    NSArray *separatorColor = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[MyColor eventCellButtonNormalBackgroundColor] CGColor], nil];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = separator.bounds;
    gradient.colors = separatorColor;
    [separator.layer insertSublayer:gradient atIndex:0];
    [cell.contentView addSubview:separator];
    
    //mask the container to get the border and round corner
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(8, 10, cellWidth - 16, 55)];
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [cell.contentView addSubview:containerView];
    
    //Now we add the member container
    UIView *membersContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height)];
    UITapGestureRecognizer *membersContainerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMembersContainerTap:)];
    [membersContainer setUserInteractionEnabled:true];
    [containerView addGestureRecognizer:membersContainerTap];
    
    UIView *memberSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, 1)];
    memberSeparator.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    [membersContainer addSubview:memberSeparator];
    
    [membersContainer addSubview:[self getNumMembersView:membersContainer.frame.size.width]];
    [containerView addSubview:membersContainer];
    
    return cell;
}

/**
 * Get and format the recommend users table view cell
 * @param tableview
 * @param indexPath
 * @return UITableViewCell
 */
-(UITableViewCell *)getEventRecommendUserTableViewCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recommendUserCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recommendUserCell"];
    
    //mask the container to get the border and round corner
    UIView *containerView = (UIView *)[cell viewWithTag:300];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    containerView.backgroundColor = [UIColor whiteColor];

    UIView *usersView = (UIView *)[cell viewWithTag:301];
    [usersView setBackgroundColor:[UIColor clearColor]];
    
    for (UIView *subview in [usersView subviews])
        [subview removeFromSuperview];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float scaleFactor = screenWidth/320;
    
    PagedUserScrollView *userScrollView = [[PagedUserScrollView alloc] initWithFrame:CGRectMake(12 * scaleFactor, 0, 296 * scaleFactor, usersView.frame.size.height)];
    userScrollView.delegate = self;
    [userScrollView setSuggestedUsers:self.recommendFriends];
    
    [usersView addSubview:userScrollView];
    
    return cell;
}

/**
 * Get and format the event description table view cell
 * @param tableview
 * @param indexPath
 * @return UITableViewCell
 */
-(UITableViewCell *)getEventDescriptionTableViewCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventDescriptionCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventDescriptionCell"];
    
    for (UIView *subview in [cell.contentView subviews])
        [subview removeFromSuperview];
    
    CGFloat viewHeight = [self calculateDescriptionViewHeight];
    CGFloat viewWidth = self.mainView.frame.size.width;
    [cell.contentView setFrame:CGRectMake(0, 0, viewWidth , viewHeight)];
    
    UIView *containerView  = [[UIView alloc] initWithFrame:CGRectMake(8, 10, viewWidth - 16, viewHeight - 15)];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    containerView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:containerView];
    
    UILabel *aboutLabel =  [[UILabel alloc] initWithFrame:CGRectMake(10, 5, viewWidth - 36, 15)];
    aboutLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    aboutLabel.text = @"About";
    [containerView addSubview:aboutLabel];
    
    UITextView *description = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, viewWidth - 36, viewHeight - 40)];
    description.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    description.scrollEnabled = NO;
    description.editable = NO;
    description.text = self.eventDetail.eDescription;
    description.dataDetectorTypes = UIDataDetectorTypeLink;
    description.backgroundColor = [UIColor clearColor];
    description.tintColor = [UIColor blueColor];
    [containerView addSubview:description];

    return cell;
}


#pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"webView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        WebViewController *viewController = segue.destinationViewController;
        WebViewUser *webViewUser = (WebViewUser *)sender;
        viewController.url = webViewUser.url;
        viewController.uid = webViewUser.uid;
        viewController.name = webViewUser.name;
    } else if ([[segue identifier] isEqualToString:@"eventWebView"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
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

@end
