//
//  MyAnnotation.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Event.h"

@interface MyAnnotation : MKPointAnnotation

@property (nonatomic, strong) Event *event;

@end
