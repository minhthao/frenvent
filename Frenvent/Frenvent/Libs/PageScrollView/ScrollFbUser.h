//
//  ScrollFbUser.h
//  Frenvent
//
//  Created by minh thao nguyen on 11/10/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuggestFriend.h"

@protocol ScrollFbUserDelegate <NSObject>
@optional
- (void)userClicked:(SuggestFriend *)suggestedUser;
- (void)hiButtonClicked:(SuggestFriend *)suggestedUser;
@end

@interface ScrollFbUser : UIView

@property (nonatomic, weak) id <ScrollFbUserDelegate> delegate;
-(void)setSuggestedUser:(SuggestFriend *)user;
@end
