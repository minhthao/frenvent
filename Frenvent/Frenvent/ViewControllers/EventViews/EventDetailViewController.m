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
#import "MyColor.h"

@interface EventDetailViewController ()

@property (nonatomic, strong) EventDetailsRequest *eventDetailsRequest;

@end

@implementation EventDetailViewController

EventDetail *completeEventDetail;

#pragma mark - initiate with delegates
- (EventDetailsRequest *)eventDetailsRequest {
    if (_eventDetailsRequest == nil) {
        _eventDetailsRequest = [[EventDetailsRequest alloc] init];
        _eventDetailsRequest.delegate = self;
    }
    return _eventDetailsRequest;
}

- (void)notifyEventDidNotExist {
    NSLog(@"not exist");
}

- (void)notifyEventDetailsQueryFail {
    
}

- (void)notifyEventDetailsQueryCompletedWithResult:(EventDetail *)eventDetail {
    NSLog(@"got result %@", eventDetail.cover);
    completeEventDetail = eventDetail;
    self.eventTitle.text = completeEventDetail.name;
    if ([completeEventDetail.cover length] > 0)
        [self.cover setImageWithURL:[NSURL URLWithString:completeEventDetail.cover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    else [self.cover setImage:[MyColor imageWithColor:[UIColor darkGrayColor]]];
    NSLog(@"%@", completeEventDetail.location);
    NSLog(@"%lld", completeEventDetail.startTime);
    NSLog(@"Event name: %@", completeEventDetail.name);
    self.title = completeEventDetail.name;
    self.eventTitle.text = completeEventDetail.name;
    NSLog(@"Event eid: %@", eventDetail.eid);
    NSLog(@"Event uid: %@", eventDetail.attendingFriends);
    self.rsvpLabel.text = completeEventDetail.rsvp;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Event eid: %@", self.eid);
    if (self.eid != nil) {
        [[self eventDetailsRequest] queryEventDetail:self.eid];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table view delegate
// Get the number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Get the number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    CGFloat height = 44;
    if (row == 0 || row == 1) {
        height = 50;
    } else if (row == 2) {
        height = 200;
    }
    return height;
}

// Get the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventDetailCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventDetailCell"];
    
    return cell;
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
