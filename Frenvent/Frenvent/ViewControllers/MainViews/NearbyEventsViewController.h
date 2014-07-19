//
//  NearbyEventsViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/17/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DbEventsRequest.h"

@interface NearbyEventsViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, DbEventsRequestDelegate>

- (IBAction)refresh:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@end
