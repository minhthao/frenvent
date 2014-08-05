//
//  EventDetailViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventDetailsRequest.h"
#import "UIImageView+AFNetworking.h"
#import "EventDetail.h"
#import "EventCoreData.h"
#import "DbEventsRequest.h"
#import "EventRsvpRequest.h"
#import "MyColor.h"
#import "ToastView.h"
#import "ShareEventRequest.h"

static NSInteger const ACTION_SHEET_RSVP_ATTENDING = 1;
static NSInteger const ACTION_SHEET_RSVP_MAYBE = 2;
static NSInteger const ACTION_SHEET_RSVP_NOT_REPLIED = 3;
static NSInteger const ACTION_SHEET_RSVP_DEFAULT = 4;
static NSInteger const ACTION_SHEET_SHARE_EVENT;

@interface EventDetailViewController ()

@property (nonatomic, strong) EventDetailsRequest *eventDetailsRequest;
@property (nonatomic, strong) EventDetail *eventDetail;
@property (nonatomic, strong) DbEventsRequest *dbEventsRequest;

@property (nonatomic, strong) UIActionSheet *rsvpActionSheetWithCurrentRsvpAttending;
@property (nonatomic, strong) UIActionSheet *rsvpActionSheetWithCurrentRsvpMaybe;
@property (nonatomic, strong) UIActionSheet *rsvpActionSheetWithCurrentRsvpNotReplied;
@property (nonatomic, strong) UIActionSheet *rsvpActionSheetDefault;
@property (nonatomic, strong) UIActionSheet *shareActionSheet;

@property (nonatomic, strong) EventRsvpRequest *eventRsvpRequest;
@property (nonatomic, strong) NSString *rsvpToChangeTo;

@property (nonatomic, strong) ShareEventRequest *shareEventRequest;

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
        }
    }
}

-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvp {
    if (success) {
        self.eventDetail.rsvp = self.rsvpToChangeTo;
        self.rsvpStatus.text = [self.eventDetail getDisplayPrivacyAndRsvp];
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


#pragma mark - delegate
- (void)notifyEventDidNotExist {
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
    [[self dbEventsRequest] uploadEvents:@[[EventCoreData getEventWithEid:eventDetail.eid]]];
    self.title = eventDetail.name;
    self.eventTitle.text = eventDetail.name;
    self.rsvpStatus.text = [eventDetail getDisplayPrivacyAndRsvp];
    if ([eventDetail.cover length] > 0)
        [self.cover setImageWithURL:[NSURL URLWithString:eventDetail.cover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    else [self.cover setImage:[MyColor imageWithColor:[UIColor darkGrayColor]]];
    
}

-(void)notifyEventsUploaded {
    [self.shareButton setEnabled:true];
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
    if (self.eid != nil) {
        [[self eventDetailsRequest] queryEventDetail:self.eid];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareAction:(id)sender {
    if ([FBDialogs canPresentMessageDialog])
        [[self shareActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    else [[self shareEventRequest] shareToWallTheEvent:self.eventDetail.eid];
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
