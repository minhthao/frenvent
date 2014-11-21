//
//  MoreTableViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "MoreTableViewController.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "EventCoreData.h"
#import "Event.h"
#import "TimeSupport.h"
#import "EventDetailViewController.h"
#import "UITableView+NXEmptyView.h"
#import "MyColor.h"
#import "MyEventManager.h"

@interface MoreTableViewController ()

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIActionSheet *logoutActionSheet;

@property (nonatomic, strong) MyEventManager *eventManager;
@property (nonatomic, strong) NSArray *allEvents;
@property (nonatomic, strong) NSArray *searchEvents;

@end

@implementation MoreTableViewController

#pragma mark - instantiation
/**
 * Lazily instantiate the empty view
 * @return UIView
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
        noResult.text = @"No matches";
        [_emptyView addSubview:noResult];
    }
    return _emptyView;
}

/**
 * Lazily instantiate logout action sheet
 * @return UIActionSheet
 */
-(UIActionSheet *)logoutActionSheet {
    if (_logoutActionSheet == nil) {
        _logoutActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
    }
    return _logoutActionSheet;
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
 * Lazily instantiate all events
 * @return NSArray
 */
- (NSArray *)allEvents {
    if (_allEvents == nil) _allEvents = [EventCoreData getAllOngoingEvents];
    return _allEvents;
}

/**
 * Lazily instantiate search events
 * @return NSArray 
 */
- (NSArray *)searchEvents {
    if (_searchEvents == nil) _searchEvents = [[NSArray alloc] init];
    return _searchEvents;
}

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.tableView.nxEV_emptyView = [self emptyView];
    [self.searchDisplayController.searchBar setTranslucent:false];
    
    UITextField *textField = [[self.searchDisplayController.searchBar subviews] objectAtIndex:1];
    [textField setFont:[UIFont fontWithName:@"SourceSansPro-Regular" size:13]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        self.navigationController.hidesBarsOnSwipe = NO;
    }
}

#pragma mark - Table view data source
// Get the number of section in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_searchBar.text == nil || [_searchBar.text length] == 0) return [[self eventManager] getNumberOfSections] + 1;
    else return 1;
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_searchBar.text == nil || [_searchBar.text length] == 0) {
        if (section == 0) return nil;
        else return [[self eventManager] getTitleForHeaderInSection:(section - 1)];
    }
    return nil;
}

// Customize the title
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section != 0 ) {
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
    } else return nil;
}

// Customize the height for the title
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0 ) return 31;
    else return 0;
}

// Get the number of row in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchBar.text == nil || [_searchBar.text length] == 0) {
        if (section == 0) return 1;
        else return [[self eventManager] getNumberOfRowsInSection:(section - 1)];
    } else return [[self searchEvents] count];
}

// Display the table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event;
    if (_searchBar.text == nil || [_searchBar.text length] == 0) {
        if (indexPath.section != 0) event = [[self eventManager] getEventAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1]];
    } else event = [[self searchEvents] objectAtIndex:indexPath.row];
    
    if (event != nil) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventItem"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:375];
        UILabel *eventName = (UILabel *)[cell viewWithTag:376];
        UILabel *eventLocation = (UILabel *)[cell viewWithTag:377];
        UILabel *eventStartTime = (UILabel *)[cell viewWithTag:378];
        UIView *border = (UIView *) [cell viewWithTag:379];
        
        [eventPicture setImageWithURL:[NSURL URLWithString:event.picture]];
        eventName.text = event.name;
        eventLocation.text = event.location;
        eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
        border.hidden = (indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1));
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileItem" forIndexPath:indexPath];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profileItem"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        UIImageView *cover = (UIImageView *)[cell viewWithTag:1];
        UIImageView *profile = (UIImageView *)[cell viewWithTag:2];
        UILabel *name = (UILabel *)[cell viewWithTag:3];
        UIButton *logoutButton = (UIButton *)[cell viewWithTag:4];
        
        //set the profile picture
        NSString *uid = [defaults objectForKey:FB_LOGIN_USER_ID];
        NSString *profileUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=150&height=150", uid];
        [profile.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [profile.layer setBorderWidth:2];
        [profile setImageWithURL:[NSURL URLWithString:profileUrl]];
        
        //set the cover
        cover.clipsToBounds = YES;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 120);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:255/255.0 green:128/255.0 blue:65/255.0 alpha:0.9] CGColor], (id)[[UIColor colorWithRed:255/255.0 green:128/255.0 blue:65/255.0 alpha:0.9] CGColor], nil];
        for (CALayer *layer in [cover.layer sublayers]) {
            [layer removeFromSuperlayer];
        }
        [cover.layer insertSublayer:gradient atIndex:0];
        NSString *coverUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=512&height=512", uid];
        [cover setImageWithURL:[NSURL URLWithString:coverUrl]];
        
        //set the name
        name.text = [defaults objectForKey:FB_LOGIN_USER_NAME];
        
        [logoutButton addTarget:self action:@selector(logoutButtonTap) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

}

//handle the selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event;
    if (_searchBar.text == nil || [_searchBar.text length] == 0) {
        if (indexPath.section != 0) event = [[self eventManager] getEventAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1]];
    } else event = [[self searchEvents] objectAtIndex:indexPath.row];
    if (event != nil) [self performSegueWithIdentifier:@"eventDetailView" sender:event.eid];

    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}

//specify the height for the table view cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((_searchBar.text == nil || [_searchBar.text length] == 0) && indexPath.section == 0) return 120;
    else return 95;
}

#pragma mark - logout logistic
/**
 * Handle the case when the logout button is pressed
 */
- (void)logoutButtonTap{
    [[self logoutActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) [self performSegueWithIdentifier:@"logoutView" sender:nil];
}

#pragma mark - search bar delegate
//handle the case where the new item is typed in the search
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.navigationController setNavigationBarHidden:YES animated:false];
    if ([searchText length] > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        _searchEvents = [[self allEvents] filteredArrayUsingPredicate:resultPredicate];
    } else {
        _searchEvents = [[NSArray alloc] init];
    }
    
    [_tableView reloadData];
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
