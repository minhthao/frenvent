//
//  RecommendFbUserRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 8/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "RecommendFbUserRequest.h"
#import "DBConstants.h"

@implementation RecommendFbUserRequest

-(void)shareUserWithUid:(NSString *)uid {
    if ([FBSession activeSession].isOpen && [[FBSession activeSession] hasGranted:@"publish_actions"]) {
        [self doShareUser:uid];
    } else if ([FBSession activeSession].isOpen) {
        [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
            if (error || ![session hasGranted:@"publish_actions"]) [self.delegate notifyRecommendFbUserRequestSuccess:false];
            else [self doShareUser:uid];
        }];
    } else if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error || !FB_ISSESSIONOPENWITHSTATE(status)) [self.delegate notifyRecommendFbUserRequestSuccess:false];
            else if (![session hasGranted:@"publish_actions"]) {
                [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                    if (error || ![session hasGranted:@"publish_actions"]) [self.delegate notifyRecommendFbUserRequestSuccess:false];
                    else [self doShareUser:uid];
                }];
            } else [self doShareUser:uid];
        }];
    } else [self.delegate notifyRecommendFbUserRequestSuccess:false];
}

-(void)doShareUser:(NSString *)uid {
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    [action setObject:[NSString stringWithFormat:@"%@?%@=%@", APP_LINK_HOST, FBUSER_UID, uid] forKey:@"person"];
    
    FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
    params.action = action;
    params.actionType = @"aneventbook:recommend";
    params.previewPropertyName = @"person";
    
    [FBDialogs presentMessageDialogWithOpenGraphActionParams:params
                                                 clientState:nil
                                                     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        if (error) [self.delegate notifyRecommendFbUserRequestSuccess:false];
        else [self.delegate notifyRecommendFbUserRequestSuccess:true];
    }];
}

@end
