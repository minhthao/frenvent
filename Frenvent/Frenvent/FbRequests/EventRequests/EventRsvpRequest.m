//
//  EventRsvpRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 8/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventRsvpRequest.h"
#import "Event.h"
#import "EventCoreData.h"

@implementation EventRsvpRequest

-(void)replyAttendingToEvent:(NSString *)eid {
    [self makeRsvpForEvent:eid usingRsvp:RSVP_ATTENDING];
}

-(void)replyUnsureToEvent:(NSString *)eid {
    [self makeRsvpForEvent:eid usingRsvp:RSVP_UNSURE];
}

-(void)replyDeclineToEvent:(NSString *)eid {
    [self makeRsvpForEvent:eid usingRsvp:RSVP_DECLINED];
}
    
/**
 * prepare for the rsvp change. This require checking permissions and add in "rsvp_event" if needed
 * @param eid
 * @param new rsvp
 */
-(void)makeRsvpForEvent:(NSString *)eid usingRsvp:(NSString *)rsvp{
    if ([FBSession activeSession].isOpen && [[FBSession activeSession] hasGranted:@"rsvp_event"]) {
        [self doRsvpForEvent:eid usingRsvp:rsvp];
    } else if ([FBSession activeSession].isOpen) {
        [[FBSession activeSession] requestNewPublishPermissions:@[@"rsvp_event"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
            if (error || ![session hasGranted:@"rsvp_event"]) [self.delegate notifyEventRsvpSuccess:false];
            else [self doRsvpForEvent:eid usingRsvp:rsvp];
        }];
    } else if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (error || !FB_ISSESSIONOPENWITHSTATE(status)) [self.delegate notifyEventRsvpSuccess:false];
                                          else if (![session hasGranted:@"rsvp_event"]) {
                                              [[FBSession activeSession] requestNewPublishPermissions:@[@"rsvp_event"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                                                  if (error || ![session hasGranted:@"rsvp_event"]) [self.delegate notifyEventRsvpSuccess:false];
                                                  else [self doRsvpForEvent:eid usingRsvp:rsvp];
                                              }];
                                          } else [self doRsvpForEvent:eid usingRsvp:rsvp];
                                      }];
    } else [self.delegate notifyEventRsvpSuccess:false];
}

/**
 * Do the rsvp for specific event
 * @param eid
 * @param rsvp
 */
-(void)doRsvpForEvent:(NSString *)eid usingRsvp:(NSString *)rsvp {
    NSMutableString *graphPath = [NSMutableString stringWithFormat:@"%@/", eid];
    if ([rsvp isEqualToString:RSVP_ATTENDING]) [graphPath appendString:@"attending"];
    else if ([rsvp isEqualToString:RSVP_UNSURE]) [graphPath appendString:@"maybe"];
    else if ([rsvp isEqualToString:RSVP_DECLINED]) [graphPath appendString:@"declined"];

    [FBRequestConnection startWithGraphPath:graphPath
                                 parameters:nil
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
      if (error) [self.delegate notifyEventRsvpSuccess:false];
      else {
          [EventCoreData updateEventWithEid:eid usingRsvp:rsvp];
          [self.delegate notifyEventRsvpSuccess:true];
      }
    }];

}

@end
