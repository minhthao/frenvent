//
//  EventDetailsRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDetail.h"

@protocol EventDetailsRequestDelegate <NSObject>
@required
- (void)notifyEventDetailsQueryFail;
- (void)notifyEventDidNotExist;
- (void)notifyEventDetailsQueryCompletedWithResult:(EventDetail *)eventDetail;
@end

@interface EventDetailsRequest : NSObject

@property (nonatomic, weak) id <EventDetailsRequestDelegate> delegate;
- (void)queryEventDetail:(NSString *)eid;

@end
