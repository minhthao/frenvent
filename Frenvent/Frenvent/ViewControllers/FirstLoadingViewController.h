//
//  FirstLoadingViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 6/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendEventsRequest.h"
#import "MyEventsRequest.h"
#import "FriendsRequest.h"
#import "DbEventsRequest.h"
#import "DbUserRequest.h"

@interface FirstLoadingViewController : UIViewController <CLLocationManagerDelegate, FriendEventsRequestDelegate, MyEventsRequestDelegate, FriendsRequestDelegate, DbEventsRequestDelegate, DbUserRequestDelegate>

@end
