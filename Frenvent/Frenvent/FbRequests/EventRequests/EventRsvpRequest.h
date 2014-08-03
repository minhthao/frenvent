//
//  EventRsvpRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventRsvpRequestDelegate <NSObject>
@required
-(void)notifyEventRsvpSuccess:(BOOL)success withRsvp:(NSString *)rsvp;
@end

@interface EventRsvpRequest : NSObject

@property (nonatomic, weak) id<EventRsvpRequestDelegate> delegate;

-(void)replyAttendingToEvent:(NSString *)eid;
-(void)replyUnsureToEvent:(NSString *)eid;
-(void)replyDeclineToEvent:(NSString *)eid;

@end
