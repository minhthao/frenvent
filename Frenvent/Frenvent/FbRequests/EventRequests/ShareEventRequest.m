//
//  ShareEventRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 8/3/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "ShareEventRequest.h"
#import "DBConstants.h"
#import "Event.h"
#import "EventDetail.h"
#import "EventCoreData.h"
#import "TimeSupport.h"

@implementation ShareEventRequest

/** 
 * Check if current active session allow sharing. If not make a request to get those permission before share
 * @param eid
 */
-(void)shareToFriendTheEventWithEid:(NSString *)eid {
    if ([FBSession activeSession].isOpen && [[FBSession activeSession] hasGranted:@"publish_actions"]) {
        [self doShareToFriendTheEventWithEid:eid];
    } else if ([FBSession activeSession].isOpen) {
        [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
            if (error || ![session hasGranted:@"publish_actions"]) [self.delegate notifyShareEventRequestSuccess:false];
            else [self doShareToFriendTheEventWithEid:eid];
        }];
    } else if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (error || !FB_ISSESSIONOPENWITHSTATE(status)) [self.delegate notifyShareEventRequestSuccess:false];
                                          else if (![session hasGranted:@"publish_actions"]) {
                                              [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                                                  if (error || ![session hasGranted:@"publish_actions"]) [self.delegate notifyShareEventRequestSuccess:false];
                                                  else [self doShareToFriendTheEventWithEid:eid];
                                              }];
                                          } else [self doShareToFriendTheEventWithEid:eid];
                                      }];
    } else [self.delegate notifyShareEventRequestSuccess:false];
}

/**
 * Share the event via message
 * @param eid
 */
-(void)doShareToFriendTheEventWithEid:(NSString *)eid {
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    [action setObject:[NSString stringWithFormat:@"%@?meid=%@", APP_LINK_HOST, eid] forKey:@"event"];
    
    FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
    params.action = action;
    params.actionType = @"aneventbook:share";
    params.previewPropertyName = @"event";
    
    [FBDialogs presentMessageDialogWithOpenGraphActionParams:params
                                                 clientState:nil
                                                     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                         if (error) [self.delegate notifyShareEventRequestSuccess:false];
                                                         else [self.delegate notifyShareEventRequestSuccess:true];
                                                     }];
}

/**
 * Share the event on wall. First check the permission before the send
 * @param eid
 */
-(void)shareToWallTheEvent:(NSString *)eid {
    if ([FBSession activeSession].isOpen && [[FBSession activeSession] hasGranted:@"publish_actions"]) {
        [self doShareToWallTheEventWithEid:eid];
    } else if ([FBSession activeSession].isOpen) {
        [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
            if (error || ![session hasGranted:@"publish_actions"]) [self.delegate notifyShareEventRequestSuccess:false];
            else [self doShareToWallTheEventWithEid:eid];
        }];
    } else if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (error || !FB_ISSESSIONOPENWITHSTATE(status)) [self.delegate notifyShareEventRequestSuccess:false];
                                          else if (![session hasGranted:@"publish_actions"]) {
                                              [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                                                  if (error || ![session hasGranted:@"publish_actions"]) [self.delegate notifyShareEventRequestSuccess:false];
                                                  else [self doShareToWallTheEventWithEid:eid];
                                              }];
                                          } else [self doShareToWallTheEventWithEid:eid];
                                      }];
    } else [self.delegate notifyShareEventRequestSuccess:false];
}

/**
 * Share the event on wall
 * @param eid
 */
-(void)doShareToWallTheEventWithEid:(NSString *)eid {
    if ([FBDialogs canPresentShareDialog]) {
        id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
        [action setObject:[NSString stringWithFormat:@"%@?eid=%@", APP_LINK_HOST, eid] forKey:@"event"];
        [action setObject: @"true" forKey: @"fb:explicitly_shared"];
        
        FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
        params.action = action;
        params.actionType = @"aneventbook:share";
        params.previewPropertyName = @"event";
        
        [FBDialogs presentShareDialogWithOpenGraphActionParams:params
                                                   clientState:nil
                                                       handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                             if (error) [self.delegate notifyShareEventRequestSuccess:false];
                                                             else [self.delegate notifyShareEventRequestSuccess:true];
                                                         }];
    } else { //user did not install facebook, so fallback using web dialog
        Event *eventToShare = [EventCoreData getEventWithEid:eid];
        if (eventToShare == nil) [self.delegate notifyShareEventRequestSuccess:false];
        else [self doShareOnWallTheEventUsingWebDialog:eventToShare];
    }
}

/**
 * Share the event on wall using fall back
 * @param eid
 */
-(void)doShareOnWallTheEventUsingWebDialog:(Event *)event {
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   event.name, @"name",
                                   [TimeSupport getFullDisplayDateTime:[event.startTime longLongValue] :[event.endTime longLongValue]] , @"caption",
                                   event.location, @"description",
                                   [NSString stringWithFormat:@"https://facebook.com/events/%@", event.eid], @"link",
                                   @"http://www.creativeapplications.net/wp-content/uploads/2010/10/Festival_Ferry-Corsten_FlashBack-Paradiso-credits-tillate.com00.jpg", @"picture",
                                   nil];
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        if (error) [self.delegate notifyShareEventRequestSuccess:false];
        else {
            if (result != FBWebDialogResultDialogNotCompleted) {
                NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                if ([urlParams valueForKey:@"post_id"]) [self.delegate notifyShareEventRequestSuccess:true];
            }
        }
    }];
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

@end
