//
//  GuestViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 11/13/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DbEventsRequest.h"

@interface GuestViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, DbEventsRequestDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *switchViewButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)doRefresh:(id)sender;

@end
