//
//  EventDetail.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventDetail.h"
#import "TimeSupport.h"

@implementation EventDetail
- (NSString *)getEventDisplayTime {
    return [TimeSupport getFullDisplayDateTime:self.startTime :self.endTime];
}
@end
