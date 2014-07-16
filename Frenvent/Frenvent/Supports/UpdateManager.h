//
//  UpdateManager.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/15/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendEventsRequest.h"
#import "MyEventsRequest.h"
#import "DbEventsRequest.h"

@interface UpdateManager : NSObject <FriendEventsRequestDelegate, MyEventsRequestDelegate, DbEventsRequestDelegate>

- (void)doUpdateWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
@end
