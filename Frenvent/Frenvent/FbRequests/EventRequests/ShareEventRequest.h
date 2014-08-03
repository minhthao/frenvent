//
//  ShareEventRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/3/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "EventDetail.h"

@protocol ShareEventRequestDelegate <NSObject>
@required
- (void)notifyShareEventRequestSuccess:(BOOL)success;
@end

@interface ShareEventRequest : NSObject

@property (nonatomic, weak) id<ShareEventRequestDelegate> delegate;

-(void)shareToFriendTheEventWithEid:(NSString *)eid;
-(void)shareToWallTheEvent:(NSString *)eid;


@end
