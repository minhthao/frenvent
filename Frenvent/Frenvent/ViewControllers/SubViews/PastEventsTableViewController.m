//
//  PastEventsTableViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/12/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PastEventsTableViewController.h"
#import "EventCoreData.h"
#import "Event.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "TimeSupport.h"
#import "Reachability.h"
#import "EventDetailViewController.h"

@interface PastEventsTableViewController ()

@property (nonatomic, strong) NSArray *pastEvents;

@end

@implementation PastEventsTableViewController
#pragma mark - initiation
- (NSArray *)pastEvents {
    if (_pastEvents == nil) _pastEvents = [EventCoreData getUserPastEvents];
    return _pastEvents;
}

#pragma mark - view delegates
- (void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:true];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self pastEvents] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pastEventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pastEventItem"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    Event *event = [[self pastEvents] objectAtIndex:indexPath.row];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    //we check if there is a internet connection, if no then stop refreshing and alert
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if ([internetReachable isReachable]) {
        Event *event = [[self pastEvents] objectAtIndex:indexPath.row];
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
        NSString *eid = (NSString *)sender;
        EventDetailViewController *viewController = segue.destinationViewController;
        viewController.eid = eid;
    }
}

@end
