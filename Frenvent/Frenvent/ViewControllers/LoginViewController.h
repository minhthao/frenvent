//
//  LoginViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/27/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <FBLoginViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end
