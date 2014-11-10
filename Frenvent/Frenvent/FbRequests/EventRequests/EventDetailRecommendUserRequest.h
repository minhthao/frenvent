//
//  EventDetailRecommendUserRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventDetailRecommendUserRequestDelegate <NSObject>
@optional
- (void)notifyEventDetailRecommendUserQueryFail;
@required
- (void)notifyEventDetailRecommendUserCompleteWithResult:(NSArray *)suggestFriends;
@end

@interface EventDetailRecommendUserRequest : NSObject
@property (nonatomic, strong) id<EventDetailRecommendUserRequestDelegate> delegate;
-(void)queryRecommendUser:(NSString *)eid;

@end
