//
//  PagedFbUserScrollView.h
//  Frenvent
//
//  Created by minh thao nguyen on 11/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedScrollView.h"
#import "ScrollFbUser.h"
#import "SuggestFriend.h"

@protocol PagedFbUserScrollViewDelegate <NSObject>
@optional
- (void)userClicked:(SuggestFriend *)suggestedUser;
- (void)hiButtonClicked:(SuggestFriend *)suggestedUser;
@end


@interface PagedFbUserScrollView : PagedScrollView <ScrollFbUserDelegate>

@property (nonatomic, weak) id<PagedFbUserScrollViewDelegate> delegate;
-(void)setSuggestedUsers:(NSArray *)users;

@end