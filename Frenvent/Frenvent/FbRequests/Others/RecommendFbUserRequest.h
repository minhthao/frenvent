//
//  RecommendFbUserRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RecommendFbUserRequestDelegate <NSObject>
@required
- (void)notifyRecommendFbUserRequestSuccess:(BOOL)success;
@end

@interface RecommendFbUserRequest : NSObject

@property (nonatomic, weak) id<RecommendFbUserRequestDelegate> delegate;

-(void)shareUserWithUid:(NSString *)uid;

@end
