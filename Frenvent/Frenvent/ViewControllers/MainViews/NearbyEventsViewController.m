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

static double const DEFAULT_LATITUDE = 37.43;
static double const DEFAULT_LONGITUDE = -122.17;

BOOL isUpdating;

@interface NearbyEventsViewController ()

@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, strong) DbEventsRequest *dbEventRequest;
@property (nonatomic, strong) NSArray *nearbyEvents;

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

#pragma mark -view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
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
        NSLog(@"%@", ((MyAnnotation *)annotation).event.name);
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
        MyAnnotation *myAnnotation = [[MyAnnotation alloc] init];
        myAnnotation.event = event;
        myAnnotation.coordinate = CLLocationCoordinate2DMake([event.latitude doubleValue], [event.longitude doubleValue]);
        myAnnotation.title = event.name;
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
    
   return [EventCoreData getNearbyEventsBoundedByLowerLongitude:lowerLong lowerLatitude:lowerLat upperLongitude:upperLong upperLatitude:upperLat];
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

- (IBAction)refresh:(id)sender {
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


@end
