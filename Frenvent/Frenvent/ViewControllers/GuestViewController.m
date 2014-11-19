//
//  GuestViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 11/13/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "GuestViewController.h"
#import "UITableView+NXEmptyView.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "TimeSupport.h"
#import "Event.h"
#import "EventCoreData.h"
#import "MyColor.h"
#import "EventManager.h"
#import "MyAnnotation.h"
#import "ToastView.h"
#import "Reachability.h"

static double const DEFAULT_LATITUDE = 37.43;
static double const DEFAULT_LONGITUDE = -122.17;

@interface GuestViewController ()

@property (nonatomic, strong) UIActionSheet *eventDetailOptionSheet;
@property (nonatomic) NSString *eventToShow;

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) NSArray *nearbyEvents;
@property (nonatomic, strong) EventManager *eventManager;

@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, strong) DbEventsRequest *dbEventRequest;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation GuestViewController

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
        noResult.text = @"No events nearby";
        [_emptyView addSubview:noResult];
    }
    return _emptyView;
}

/**
 * Lazily instantiate event detail action sheet
 * @return UIActionSheet
 */
-(UIActionSheet *)eventDetailOptionSheet {
    if (_eventDetailOptionSheet == nil) {
        _eventDetailOptionSheet = [[UIActionSheet alloc] initWithTitle:@"View event detail using" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"TappedIn (require login)", @"Facebook",  nil];
    }
    return _eventDetailOptionSheet;
}

/**
 * Lazily instantiate the db event request
 * @return DbEventsRequest
 */
- (DbEventsRequest *)dbEventRequest {
    if (_dbEventRequest == nil) {
        _dbEventRequest = [[DbEventsRequest alloc] init];
        _dbEventRequest.delegate = self;
    }
    return _dbEventRequest;
}

/**
 * Lazily instantiate and get the event manager object
 * @return Event Manager
 */
- (EventManager *) eventManager {
    if (_eventManager == nil) {
        _eventManager = [[EventManager alloc] init];
        _eventManager.filterType = FILTER_TYPE_DEFAULT;
    }
    
    return _eventManager;
}

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

#pragma mark - selectors and click actions
/**
 * Switch views - either from the list to the map, or from the map to the list
 */
-(void)switchViewButtonClick {
    if (self.tableView.hidden == YES) {
        self.mapView.hidden = YES;
        self.tableView.hidden = NO;
        self.switchViewButton.text = @"Show events in a map";
    } else {
        self.mapView.hidden = NO;
        self.tableView.hidden = YES;
        self.switchViewButton.text = @"Show events in a list ";
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://event/%@", self.eventToShow]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
        else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://facebook.com/events/%@", self.eventToShow]]];
    }
}

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true;
    self.tableView.nxEV_emptyView = [self emptyView];
    self.tableView.hidden = YES;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.hidden = NO;
    self.refreshButton.enabled = NO;
    
    self.switchViewButton.text = @"Show events in a list";
    self.switchViewButton.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchViewButtonClick)];
    [self.switchViewButton addGestureRecognizer:tapGesture];

    if ([[self locationManager] respondsToSelector:@selector(requestAlwaysAuthorization)])
        [[self locationManager] requestAlwaysAuthorization];
    
    [[self locationManager] startUpdatingLocation];
}

#pragma mark - location manager delegates
//delegate for location manager, call back for reauthorization
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [[self locationManager] stopUpdatingLocation];
}

//delegate for location manager, call back for location update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[self locationManager] stopUpdatingLocation];
}

- (IBAction)doRefresh:(id)sender {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if (![internetReachable isReachable]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet to get more accurate results."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    } else {
        MKCoordinateRegion region = [self.mapView region];
        CLLocationCoordinate2D center = region.center;
        double latitudeDelta = region.span.latitudeDelta;
        double longitudeDelta = region.span.longitudeDelta;
        
        double lowerLong = center.longitude - longitudeDelta;
        double lowerLat = center.latitude - latitudeDelta;
        
        double upperLong = center.longitude + longitudeDelta;
        double upperLat = center.latitude + latitudeDelta;
        
        [[self dbEventRequest] refreshNearbyEvents:lowerLong :lowerLat :upperLong :upperLat];
        [self createAndDisplayPin];
    }
    
    [self.refreshButton setEnabled:false];
}

#pragma mark - DB event request delegate
/**
 * Either on failure or successful, display what we have
 * @return array of events
 */
-(void)notifyNearbyEventsRefreshedWithResults:(NSArray *)events {
    MKCoordinateRegion region = [self.mapView region];
    self.nearbyEvents = [self getEvents:region];
    [self createAndDisplayPin];
}

-(void)notifyEventRequestFailure {
    MKCoordinateRegion region = [self.mapView region];
    self.nearbyEvents = [self getEvents:region];
    [self createAndDisplayPin];
}

#pragma mark - map delegates
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    [self.refreshButton setEnabled:true];
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        self.eventToShow = ((MyAnnotation *)annotation).event.eid;
        [[self eventDetailOptionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView) {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            pinView.rightCalloutAccessoryView.frame = CGRectZero;
            
            // Add an image to the left callout.
            UIImageView *eventPicture = [[UIImageView alloc] initWithFrame:CGRectMake(pinView.frame.origin.x, pinView.frame.origin.y, pinView.frame.size.height, pinView.frame.size.height)];
            eventPicture.contentMode = UIViewContentModeScaleAspectFill;
            [eventPicture setImageWithURL:[NSURL URLWithString:((MyAnnotation *)annotation).event.picture]];
            
            pinView.leftCalloutAccessoryView = eventPicture;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

//on update of location, check if no results are being display, initiate and display them
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.currentLocation = userLocation.location;
    if (self.nearbyEvents == nil) {
        double defaultDistance = 25000;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([self.currentLocation coordinate], defaultDistance, defaultDistance);
        CLLocationCoordinate2D center = region.center;
        double latitudeDelta = region.span.latitudeDelta;
        double longitudeDelta = region.span.longitudeDelta;
        
        double lowerLong = center.longitude - longitudeDelta;
        double lowerLat = center.latitude - latitudeDelta;
        
        double upperLong = center.longitude + longitudeDelta;
        double upperLat = center.latitude + latitudeDelta;
        
        [[self dbEventRequest] refreshNearbyEvents:lowerLong :lowerLat :upperLong :upperLat];
        
        [self.mapView setRegion:region animated:YES];
        [self createAndDisplayPin];
    }
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    self.currentLocation = [[CLLocation alloc] initWithLatitude:DEFAULT_LATITUDE longitude:DEFAULT_LONGITUDE];
    if (self.nearbyEvents == nil) {
        double defaultDistance = 25000;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([self.currentLocation coordinate], defaultDistance, defaultDistance);
        CLLocationCoordinate2D center = region.center;
        double latitudeDelta = region.span.latitudeDelta;
        double longitudeDelta = region.span.longitudeDelta;
        
        double lowerLong = center.longitude - longitudeDelta;
        double lowerLat = center.latitude - latitudeDelta;
        
        double upperLong = center.longitude + longitudeDelta;
        double upperLat = center.latitude + latitudeDelta;
        
        [[self dbEventRequest] refreshNearbyEvents:lowerLong :lowerLat :upperLong :upperLat];
        
        [self.mapView setRegion:region animated:YES];
        [self createAndDisplayPin];
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [ToastView showToastInParentView:self.view withText:@"Tap refresh button on top to reload" withDuaration:3.0];
}

#pragma mark - private methods
//Create and display the pin
- (void)createAndDisplayPin {
    [self.mapView removeAnnotations:_annotations];
    
    NSMutableArray *newAnnotations = [[NSMutableArray alloc] init];
    
    for (Event *event in _nearbyEvents) {
        MyAnnotation *myAnnotation = [[MyAnnotation alloc] init];
        myAnnotation.event = event;
        myAnnotation.coordinate = CLLocationCoordinate2DMake([event.latitude doubleValue], [event.longitude doubleValue]);
        
        myAnnotation.title = ([event.name length] <= 23 ? event.name : [NSString stringWithFormat:@"%@...", [event.name substringToIndex:22]]);
        myAnnotation.subtitle = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
        [newAnnotations addObject:myAnnotation];
    }
    
    _annotations = newAnnotations;
    [self.mapView addAnnotations:_annotations];
}

/**
 * Get the events within the region
 * @param coordinate region
 * @return Array of Event
 */
- (NSArray *)getEvents:(MKCoordinateRegion) region {
    CLLocationCoordinate2D center = region.center;
    double latitudeDelta = region.span.latitudeDelta;
    double longitudeDelta = region.span.longitudeDelta;
    
    double lowerLong = center.longitude - longitudeDelta;
    double lowerLat = center.latitude - latitudeDelta;
    
    double upperLong = center.longitude + longitudeDelta;
    double upperLat = center.latitude + latitudeDelta;
    
    NSArray *events = [EventCoreData getNearbyEventsBoundedByLowerLongitude:lowerLong lowerLatitude:lowerLat upperLongitude:upperLong upperLatitude:upperLat];
    
    if (self.currentLocation != nil)
        [[self eventManager] setEvents:events withCurrentLocation:self.currentLocation];
    else [[self eventManager] setEvents:events];
    
    [self.tableView reloadData];
    
    return events;
}

#pragma mark - Table view data source
// Get the number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.eventManager ? [[self eventManager] getNumberOfSections] : 0;
}

// Get the section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.eventManager ? [[self eventManager] getTitleAtSection:section] : nil;
}

// Customize the title
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
}

// Customize the height for the title
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 31;
}

// Get the number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.eventManager ? [[[self eventManager] getEventsAtSection:section] count] : 0;
}

// Get the cell in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventItem"];
    
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    
    UIImageView *eventPicture = (UIImageView *)[cell viewWithTag:375];
    UILabel *eventName = (UILabel *)[cell viewWithTag:376];
    UILabel *eventLocation = (UILabel *)[cell viewWithTag:377];
    UILabel *eventStartTime = (UILabel *)[cell viewWithTag:378];
    UILabel *eventDistance = (UILabel *)[cell viewWithTag:380];
    
    [eventPicture setImageWithURL:[NSURL URLWithString:event.picture]];
    eventName.text = event.name;
    eventLocation.text = event.location;
    eventStartTime.text = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
    eventDistance.text =  [event getDistanceString];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    Event *event = [[[self eventManager] getEventsAtSection:indexPath.section] objectAtIndex:indexPath.row];
    self.eventToShow = event.eid;
    [[self eventDetailOptionSheet] showInView:[UIApplication sharedApplication].keyWindow];
}

@end
