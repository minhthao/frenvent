//
//  FriendInfoViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FbUserInfoViewController.h"
#import "FbUserInfoRequest.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "Friend.h"
#import "MyColor.h"
#import "WebViewController.h"
#import "Event.h"
#import "TimeSupport.h"
#import "EventDetailViewController.h"
#import "PagedPhotoScrollView.h"
#import "PagedEventScrollView.h"
#import "FbUserPhotoViewController.h"

@interface FbUserInfoViewController ()

@property (nonatomic, strong) FbUserInfoRequest *fbUserInfoRequest;
@property (nonatomic, strong) NSArray *ongoingEvents;
@property (nonatomic, strong) NSArray *pastEvents;
@property (nonatomic, strong) NSArray *photoUrls;

@end

@implementation FbUserInfoViewController
#pragma mark - initiation and private methods
- (FbUserInfoRequest *)fbUserInfoRequest {
    if (_fbUserInfoRequest == nil) {
        _fbUserInfoRequest = [[FbUserInfoRequest alloc] init];
        _fbUserInfoRequest.delegate = self;
    }
    return _fbUserInfoRequest;
}

- (void)maskButtonView:(UIView *)view {
    [view setClipsToBounds:true];
    [view.layer setCornerRadius:3.0f];
    [view.layer setMasksToBounds:YES];
    [view.layer setBorderWidth:2.5f];
    [view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (void)maskPagedScrollView:(UIView *)view {
    [view.layer setMasksToBounds:NO];
    [view.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [view.layer setShadowRadius:3.5f];
    [view.layer setShadowOffset:CGSizeMake(1, 1)];
    [view.layer setShadowOpacity:0.5];

}

#pragma mark - alert view delegate
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
     [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - paged scroll view delegate
-(void)imageIndexClicked:(int)index {
    [self performSegueWithIdentifier:@"photoView" sender:[NSNumber numberWithInt:index]];
}

-(void)eventClicked:(Event *)event {
    [self performSegueWithIdentifier:@"eventDetailView" sender:event.eid];
}

-(void)eventRsvpButtonClicked:(Event *)event {
    NSLog(@"rsvp clicked");
}

#pragma mark - Fb user info request delegate
-(void) notifyFbUserInfoRequestFail {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"User did not exist or you don't have permission to access this user."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

-(void) fbUserInfoRequestMutualFriendsCount:(int16_t)mutualFriendsCount {
    self.numMutualFriends.text = [NSString stringWithFormat:@"%d mutual friends", mutualFriendsCount];
}

-(void) fbUserInfoRequestName:(NSString *)name {
    self.username.text = name;
}

-(void) fbUserInfoRequestOngoingEvents:(NSArray *)ongoingEvents {
    self.ongoingEvents = ongoingEvents;
    if ([self.ongoingEvents count] > 0) {
        [self.eventTable reloadData];
        
        [self.eventsView setHidden:true];
        PagedEventScrollView *pageScrollView = [[PagedEventScrollView alloc] initWithFrame:self.eventsView.frame];
        pageScrollView.delegate = self;
        [self maskPagedScrollView:pageScrollView];
        [pageScrollView setBackgroundColor:[MyColor eventCellButtonsContainerBorderColor]];
        [pageScrollView setEvents:self.ongoingEvents];
        
        [self.mainContentView addSubview:pageScrollView];
    } else {
        UIImageView *noEventImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
        noEventImage.contentMode = UIViewContentModeScaleToFill;
        [noEventImage setImage:[UIImage imageNamed:@"PagedEventScrollViewNoEvent"]];
        [self.eventsView addSubview:noEventImage];
    }
}

-(void) fbUserInfoRequestPhotos:(NSArray *)urls {
    for (UIView *subview in [self.photosView subviews]) {
        [subview removeFromSuperview];
    }
    if ([urls count] > 0) {
        self.photoUrls = urls;
        [self.photosView setHidden:true];
        
        PagedPhotoScrollView *pageScrollView = [[PagedPhotoScrollView alloc] initWithFrame:self.photosView.frame];
        pageScrollView.delegate = self;
        [self maskPagedScrollView:pageScrollView];
        [pageScrollView setBackgroundColor:[MyColor eventCellButtonsContainerBorderColor]];
        [pageScrollView setScrollViewPhotoUrls:urls withContentModeFit:false];
        
        [self.mainContentView addSubview:pageScrollView];
    } else {
        UIImageView *noPhotoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        noPhotoImage.contentMode = UIViewContentModeScaleToFill;
        [noPhotoImage setImage:[UIImage imageNamed:@"PagedEventScrollViewNoPhoto"]];
        [self.photosView addSubview:noPhotoImage];
    }
}

-(void) fbUserInfoRequestPastEvents:(NSArray *)pastEvents {
    self.pastEvents = pastEvents;
    if ([self.pastEvents count] > 0) [self.eventTable reloadData];
}

-(void) fbUserInfoRequestProfileCover:(NSString *)cover {
    //we first setup the view
    [self.mainContentView setHidden:false];
    [self.loadingSpinner stopAnimating];
    [self.viewSegmentControl setEnabled:true];
    [self.viewSegmentControl setSelectedSegmentIndex:0];
    [self.shareButton setEnabled:true];
    
    
    if ([cover length] > 0)
        [self.coverImage setImageWithURL:[NSURL URLWithString:cover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    else [self.coverImage setImage:[MyColor imageWithColor:[UIColor darkGrayColor]]];   
    
}

#pragma mark - button tap
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleProfileButtonTap:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"webView" sender:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", self.targetUid]];
}

- (void)handleMessageButtonTap:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"webView" sender:[NSString stringWithFormat:@"https://m.facebook.com/messages/compose?ids=%@", self.targetUid]];}

- (void)handlePhotoButtonTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"photo button tap");
    [self performSegueWithIdentifier:@"webView" sender:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?v=photos&id=%@", self.targetUid]];
}

- (void)handleFriendButtonTap:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"webView" sender:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?v=friends&id=%@", self.targetUid]];}

#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mainContentView setHidden:true];
    [self.eventTable setHidden:true];
    [self.loadingSpinner setHidesWhenStopped:true];
    [self.loadingSpinner startAnimating];
    [self.shareButton setEnabled:false];
    [self.viewSegmentControl setEnabled:false];
    
    UITapGestureRecognizer *profileButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileButtonTap:)];
    [self.profileButton addGestureRecognizer:profileButtonTap];
    
    UITapGestureRecognizer *messageButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMessageButtonTap:)];
    [self.messageButton addGestureRecognizer:messageButtonTap];
    
    UITapGestureRecognizer *photoButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePhotoButtonTap:)];
    [self.photosButton addGestureRecognizer:photoButtonTap];
    
    UITapGestureRecognizer *friendButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendButtonTap:)];
    [self.friendsButton addGestureRecognizer:friendButtonTap];
    
    //view load
    if (self.targetUid != nil) {
        NSString *profilePictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", self.targetUid];
        [self.profileImage setImageWithURL:[NSURL URLWithString:profilePictureUrl]];
        
        [[self fbUserInfoRequest] queryFbUserInfo:self.targetUid];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.profileImage.layer setMasksToBounds:YES];
    [self.profileImage.layer setBorderWidth:3];
    [self.profileImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [self maskButtonView:self.profileButton];
    [self maskButtonView:self.messageButton];
    [self maskButtonView:self.photosButton];
    [self maskButtonView:self.friendsButton];
    
    [self maskPagedScrollView:self.eventsView];
    [self maskPagedScrollView:self.photosView];
    [self maskPagedScrollView:self.suggestedFriendView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view segment
- (IBAction)viewSegments:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger index = [segmentedControl selectedSegmentIndex];
    
    if (index == 0) {
        [self.mainContentView setHidden:false];
        [self.eventTable setHidden:true];
    } else if (index == 1) {
        [self.mainContentView setHidden:true];
        [self.eventTable setHidden:false];
    }
}

- (IBAction)shareClicked:(id)sender {
}

#pragma mark - table view delegate
// Get the number of section in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger numSections = 0;
    if ([self.ongoingEvents count] > 0) numSections++;
    if ([self.pastEvents count] > 0) numSections++;
    return numSections;
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && [self.ongoingEvents count] > 0) return @"FUTURE EVENTS";
    else if ((section == 0 && [self.ongoingEvents count] == 0) || section == 1) return @"PAST EVENTS";
    else return nil;
}

// Get the number of row in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [self.ongoingEvents count] > 0) return [self.ongoingEvents count];
    else if ((section == 0 && [self.ongoingEvents count] == 0) || section == 1) return [self.pastEvents count];
    else return 0;
    
}


// Display the table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fbUserEventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fbUserEventItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    Event *event;
    if (indexPath.section == 0 && [self.ongoingEvents count] > 0)
        event = [self.ongoingEvents objectAtIndex:indexPath.row];
    else if ((indexPath.section == 0 && [self.ongoingEvents count] == 0) || indexPath.section == 1)
        event = [self.pastEvents objectAtIndex:indexPath.row];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:400];
    UILabel *eventName = (UILabel *)[cell viewWithTag:401];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:402];
    UILabel *eventHost = (UILabel *)[cell viewWithTag:403];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:404];
    
    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
    eventName.text = event.name;
    eventLocation.text = event.location;
    eventHost.attributedText = [event getHostAttributedString];
    
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    return cell;
}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event;
    if (indexPath.section == 0 && [self.ongoingEvents count] > 0) event =
        [self.ongoingEvents objectAtIndex:indexPath.row];
    else if ((indexPath.section == 0 && [self.ongoingEvents count] == 0) || indexPath.section == 1)
        event = [self.pastEvents objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"eventDetailView" sender:event.eid];
}

#pragma mark - segue preparation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToSelf"]) {
        NSString *uid = (NSString *)sender;
        FbUserInfoViewController *viewController = segue.destinationViewController;
        viewController.targetUid = uid;
    } else if ([[segue identifier] isEqualToString:@"webView"]) {
        WebViewController *viewController = segue.destinationViewController;
        viewController.url = (NSString *)sender;
    } else if ([[segue identifier] isEqualToString:@"eventDetailView"]) {
        NSString *eid = (NSString *)sender;
        EventDetailViewController *viewController = segue.destinationViewController;
        viewController.eid = eid;
    } else if ([[segue identifier] isEqualToString:@"photoView"]) {
        int photoIndex = [(NSNumber *)sender intValue];
        FbUserPhotoViewController *viewController = segue.destinationViewController;
        viewController.photoUrls = self.photoUrls;
        viewController.index = photoIndex;
    }
}

@end
