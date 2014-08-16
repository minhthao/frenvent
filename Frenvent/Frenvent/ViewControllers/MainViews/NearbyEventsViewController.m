//
//  NearbyEventsViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/17/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "NearbyEventsViewController.h"
#import "EventCoreData.h"
#import "DbEventsRequest.h"
#import "MyAnnotation.h"
#import "TimeSupport.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "EventDetailViewController.h"
#import "TimeSupport.h"

static double const DEFAULT_LATITUDE = 37.43;
static double const DEFAULT_LONGITUDE = -122.17;

static NSInteger const FILTER_TYPE_TODAY_EVENT = 0;
static NSInteger const FILTER_TYPE_TOMORROW_EVENT = 1;
static NSInteger const FILTER_TYPE_WEEKEND_EVENT = 2;
static NSInteger const FILTER_TYPE_ALL_EVENT = 3;


BOOL isUpdating;

@interface NearbyEventsViewController ()

@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, strong) DbEventsRequest *dbEventRequest;
@property (nonatomic, strong) NSArray *nearbyEvents;

@property (nonatomic, strong) UIActionSheet *filterActionSheet;
@property (nonatomic) NSInteger filterType;

@end

@implementation NearbyEventsViewController

#pragma mark - private initialization
- (DbEventsRequest *)dbEventRequest {
    if (_dbEventRequest == nil) {
        _dbEventRequest = [[DbEventsRequest alloc] init];
        _dbEventRequest.delegate = self;
    }
    return _dbEventRequest;
}

- (UIActionSheet *)filterActionSheet {
    if (_filterActionSheet == nil) {
        _filterActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select event time" delegate:self cancelButtonTitle:@"default" destructiveButtonTitle:nil otherButtonTitles:@"Today", @"Tomorrow", @"Weekend", nil];
        _filterActionSheet.delegate = self;
    }
    return _filterActionSheet;
}

#pragma mark - some private methods to help classify the events
-(BOOL)isOfTypeTodayEvent:(Event *)event {
    return ([event.startTime longLongValue] >= [TimeSupport getTodayTimeFrameStartTimeInUnix] &&
            [event.startTime longLongValue] < [TimeSupport getTodayTimeFrameEndTimeInUnix]);
}

-(BOOL)isOfTypeTomorrowEvent:(Event *)event {
    return ([event.startTime longLongValue] >= [TimeSupport getTodayTimeFrameEndTimeInUnix] &&
            [event.startTime longLongValue] < ([TimeSupport getTodayTimeFrameEndTimeInUnix] + 60 * 60 * 24));
}

-(BOOL)isOfTypeWeekendEvent:(Event *)event {
    return ([event.startTime longLongValue] >= [TimeSupport getThisWeekendTimeFrameStartTimeInUnix] &&
            [event.startTime longLongValue] < [TimeSupport getThisWeekendTimeFrameEndTimeInUnix]);
}

-(BOOL)isWithinFilteredSet:(Event *)event {
    return (self.filterType == FILTER_TYPE_ALL_EVENT ||
            (self.filterType == FILTER_TYPE_TODAY_EVENT && [self isOfTypeTodayEvent:event]) ||
            (self.filterType == FILTER_TYPE_TOMORROW_EVENT && [self isOfTypeTomorrowEvent:event]) ||
            (self.filterType == FILTER_TYPE_WEEKEND_EVENT && [self isOfTypeWeekendEvent:event]));
}

#pragma mark -view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    self.filterType = FILTER_TYPE_ALL_EVENT;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.mapView setShowsUserLocation:YES];
    [self.refreshButton setEnabled:false];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DB event request delegate
/**
 * Either on failure or successful, display what we have
 */
-(void)notifyNearbyEventsRefreshedWithResults:(NSArray *)events {
    MKCoordinateRegion region = [self.mapView region];
    _nearbyEvents = [self getEvents:region];
    [self createAndDisplayPin];
}

-(void)notifyEventRequestFailure {
    MKCoordinateRegion region = [self.mapView region];
    _nearbyEvents = [self getEvents:region];
    [self createAndDisplayPin];
}

#pragma mark - map delegates
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    [self.refreshButton setEnabled:true];
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        [self performSegueWithIdentifier:@"eventDetailView" sender:((MyAnnotation *)annotation).event.eid];
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
            
            // Add an image to the left callout.
            UIImageView *eventPicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [eventPicture setImageWithURL:[NSURL URLWithString:((MyAnnotation *)annotation).event.picture] placeholderImage:[UIImage imageNamed:@"placeholder.png"] ];
            
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
    if (_nearbyEvents == nil) {
        BOOL hasEventsInRegions = false;
        double defaultDistance = 1000;
        while (!hasEventsInRegions) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([userLocation coordinate], defaultDistance, defaultDistance);
            NSArray *eventsInRegion = [self getEvents:region];
            if ([eventsInRegion count] > 0) {
                _nearbyEvents = eventsInRegion;
                hasEventsInRegions = true;
                
                [self.mapView setRegion:region animated:YES];
                [self createAndDisplayPin];
            }
            defaultDistance *= 2;
        }
    }
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    //if unable to locate user current location, then use stanford as default location, radius 10 miles
    if (_nearbyEvents == nil) {
        CLLocationCoordinate2D defaultLocation = CLLocationCoordinate2DMake(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(defaultLocation, 5000, 5000);
        [self.mapView setRegion:region animated:YES];
        _nearbyEvents = [self getEvents:region];
        [self createAndDisplayPin];
    }
}

#pragma mark - private methods
//Create and display the pin
- (void)createAndDisplayPin {
    [self.mapView removeAnnotations:_annotations];
    
    NSMutableArray *newAnnotations = [[NSMutableArray alloc] init];
    
    for (Event *event in _nearbyEvents) {
        if ([self isWithinFilteredSet:event]) {
            MyAnnotation *myAnnotation = [[MyAnnotation alloc] init];
            myAnnotation.event = event;
            myAnnotation.coordinate = CLLocationCoordinate2DMake([event.latitude doubleValue], [event.longitude doubleValue]);
            myAnnotation.title = event.name;
            myAnnotation.subtitle = [TimeSupport getDisplayDateTime:[event.startTime longLongValue]];
            [newAnnotations addObject:myAnnotation];
        }
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
    
    return [EventCoreData getNearbyEventsBoundedByLowerLongitude:lowerLong lowerLatitude:lowerLat upperLongitude:upperLong upperLatitude:upperLat];
}

- (IBAction)refresh:(id)sender {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    if (![internetReachable isReachable]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                          message:@"Connect to internet to get more accurate results."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }

    
    [self.refreshButton setEnabled:false];
    
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

#pragma mark - UIActionSheet and filter
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.filterType != buttonIndex) {
        self.filterType = buttonIndex;
        switch (buttonIndex) {
            case FILTER_TYPE_ALL_EVENT:
                self.filterButton.title = @"Filter";
                break;
                
            case FILTER_TYPE_TODAY_EVENT:
                self.filterButton.title = @"Today";
                break;
                
            case FILTER_TYPE_TOMORROW_EVENT:
                self.filterType = buttonIndex;
                break;
                
            case FILTER_TYPE_WEEKEND_EVENT:
                self.filterType = buttonIndex;
                break;
                
            default:
                break;
        }
        [self refresh:nil];
    }
    
}

- (IBAction)doFilter:(id)sender {
    [[self filterActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
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
