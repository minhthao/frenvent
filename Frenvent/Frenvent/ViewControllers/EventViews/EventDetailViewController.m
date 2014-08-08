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

@property (nonatomic, strong) PagedUserScrollView *userScrollView;

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
        _shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share with friends", @"Share on wall", nil];
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
 * Lazily instantiate the user scroll ciew
 * @return user scroll view
 */
- (PagedUserScrollView *)userScrollView {
    if (_userScrollView == nil) {
        _userScrollView = [[PagedUserScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
        _userScrollView.delegate = self;
    }
    return _userScrollView;
}


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
    
    if (![event canRsvp]) [self.joinButton setEnabled:false];
    [self refreshJoinButtonView];
    if ([[event markType] intValue] == MARK_TYPE_FAVORITE) [self.saveButton setSelected:true];
    else [self.saveButton setSelected:false];
    
    if ([event canShare]) [self.shareButton setEnabled:true];
    
    self.title = eventDetail.name;
    self.eventTitle.text = eventDetail.name;
    self.rsvpStatus.text = [eventDetail getDisplayPrivacyAndRsvp];
    if ([eventDetail.cover length] > 0)
        [self.cover setImageWithURL:[NSURL URLWithString:eventDetail.cover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    else [self.cover setImage:[MyColor imageWithColor:[UIColor darkGrayColor]]];
    
    self.startTime.text = [eventDetail getEventDisplayTime];
    
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
        if ([self.recommendFriends count] > 0)[[self userScrollView] setSuggestedUsers:self.recommendFriends];
        [self.mainView reloadData];
    }
}

#pragma mark - alert view
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:true];
    [self.shareButton setEnabled:false];
    
    self.mainView.contentInset = UIEdgeInsetsMake(0, 0, self.navigationController.navigationBar.frame.size.height, 0);
    
    if (self.eid != nil) {
        [[self eventDetailsRequest] queryEventDetail:self.eid];
        [[self eventDetailRecommendUserRequest] queryRecommendUser:self.eid];
    }
    
    [self.loadingSpinner setHidesWhenStopped:true];
    [self.loadingSpinner startAnimating];
    [self.mainView setHidden:true];
    
    NSArray *containerColor = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[MyColor eventCellButtonsContainerBorderColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.buttonViewsContainer.bounds;
    gradient.colors = containerColor;
    [self.buttonViewsContainer.layer insertSublayer:gradient atIndex:0];
    
    [self formatMenuButton:self.joinButton];
    [self formatMenuButton:self.saveButton];
    [self formatMenuButton:self.moreButton];

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
    [self.joinButton setHighlighted:true];
    
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
        [self.saveButton setSelected:false];
    } else {
        [EventCoreData setEventMarkType:event withType:MARK_TYPE_FAVORITE];
        [self.saveButton setSelected:true];
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
        [self.joinButton setSelected:true];
    else {
        [self.joinButton setSelected:false];
        [self.joinButton setHighlighted:false];
    }
}

-(void)formatMenuButton:(UIButton *)button {
    NSArray *buttonsColor = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0] CGColor], nil];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = button.bounds;
    gradient.colors = buttonsColor;
    [button.layer insertSublayer:gradient atIndex:0];
    [button bringSubviewToFront:button.imageView];
}

- (void)maskShadowView:(UIView *)view {
    [view.layer setMasksToBounds:NO];
    [view.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [view.layer setShadowRadius:3.5f];
    [view.layer setShadowOffset:CGSizeMake(1, 1)];
    [view.layer setShadowOpacity:0.5];
}

#pragma mark - table view delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.eventDetail != nil) {
        if ([self.eventDetail.description length] > 0) return 2;
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
            } else return 165;
        } else {
            if (indexPath.row == 0) {
                if ([self.eventDetail.attendingFriends count] > 0) return 155;
                else return 70;
            } else return 165;
        }
    } else return [self calculateDescriptionViewHeight];
}

-(CGFloat)calculateDescriptionViewHeight {
    UITextView *tempView = [[UITextView alloc] init];
    tempView.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    tempView.text = self.eventDetail.description;
    
    CGSize textViewSize = [tempView sizeThatFits:CGSizeMake(284, FLT_MAX)];
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
    
    UITapGestureRecognizer *navigationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLocationButtonTap:)];
    [cell.contentView setUserInteractionEnabled:true];
    [cell.contentView addGestureRecognizer:navigationTap];
    
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:101];
    
    locationLabel.text = self.eventDetail.location;
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
    
    //add the shadow to separate the top views
    UIView *separator = (UIView *)[cell viewWithTag:207];
    NSArray *separatorColor = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[MyColor eventCellButtonNormalBackgroundColor] CGColor], nil];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = separator.bounds;
    gradient.colors = separatorColor;
    [separator.layer insertSublayer:gradient atIndex:0];
    
    //mask the container to get the border and round corner
    UIView *containerView = (UIView *)[cell viewWithTag:200];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];

    //add the list of friends interested
    UIView *friendsAttendingView = (UIView *)[cell viewWithTag:201];
    for (UIView *subview in [friendsAttendingView subviews]) {
        [subview removeFromSuperview];
    }
    
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
    
    //display the text of friend attendings and member
    UILabel *friendsAttending = (UILabel *)[cell viewWithTag:202];
    friendsAttending.attributedText = [self.eventDetail getFriendsInterested];
    
    UIView *membersContainer = (UIView *)[cell viewWithTag:203];
    UITapGestureRecognizer *membersContainerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMembersContainerTap:)];
    [membersContainer setUserInteractionEnabled:true];
    [containerView addGestureRecognizer:membersContainerTap];
    
    UILabel *numGoing = (UILabel *)[cell viewWithTag:204];
    UILabel *numMaybe = (UILabel *)[cell viewWithTag:205];
    UILabel *numInvited = (UILabel *)[cell viewWithTag:206];
    
    numGoing.text = [NSString stringWithFormat:@"%d", self.eventDetail.attendingCount];
    numMaybe.text = [NSString stringWithFormat:@"%d", self.eventDetail.unsureCount];
    numInvited.text = [NSString stringWithFormat:@"%d", self.eventDetail.unrepliedCount];
    return cell;
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
    
    //add the shadow to separate the top views
    UIView *separator = (UIView *)[cell viewWithTag:207];
    NSArray *separatorColor = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[MyColor eventCellButtonNormalBackgroundColor] CGColor], nil];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = separator.bounds;
    gradient.colors = separatorColor;
    [separator.layer insertSublayer:gradient atIndex:0];
    
    //mask the container to get the border and round corner
    UIView *containerView = (UIView *)[cell viewWithTag:200];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    //display the num members
    UIView *membersContainer = (UIView *)[cell viewWithTag:203];
    UITapGestureRecognizer *membersContainerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMembersContainerTap:)];
    [membersContainer setUserInteractionEnabled:true];
    [containerView addGestureRecognizer:membersContainerTap];
    
    UILabel *numGoing = (UILabel *)[cell viewWithTag:204];
    UILabel *numMaybe = (UILabel *)[cell viewWithTag:205];
    UILabel *numInvited = (UILabel *)[cell viewWithTag:206];
    
    numGoing.text = [NSString stringWithFormat:@"%d", self.eventDetail.attendingCount];
    numMaybe.text = [NSString stringWithFormat:@"%d", self.eventDetail.unsureCount];
    numInvited.text = [NSString stringWithFormat:@"%d", self.eventDetail.unrepliedCount];
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
    [self maskShadowView:containerView];
    for (UIView *subviews in [containerView subviews])
        [subviews removeFromSuperview];
    
    [containerView addSubview:[self userScrollView]];
    
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
    [cell.contentView setFrame:CGRectMake(0, 0, 320, viewHeight)];
    
    UIView *containerView  = [[UIView alloc] initWithFrame:CGRectMake(8, 10, 304, viewHeight - 15)];
    [containerView.layer setCornerRadius:3.0f];
    [containerView.layer setMasksToBounds:YES];
    [containerView.layer setBorderWidth:0.5f];
    [containerView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    containerView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:containerView];
    
    UILabel *aboutLabel =  [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 284, 15)];
    aboutLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    aboutLabel.text = @"About";
    [containerView addSubview:aboutLabel];
    
    UITextView *description = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, 284, viewHeight - 40)];
    description.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    description.scrollEnabled = NO;
    description.editable = NO;
    description.text = self.eventDetail.description;
    description.dataDetectorTypes = UIDataDetectorTypeLink;
    description.backgroundColor = [UIColor clearColor];
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
