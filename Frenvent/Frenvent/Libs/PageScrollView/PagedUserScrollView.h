//
//  PagedUserScrollView.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/31/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedScrollView.h"
#import "ScrollUser.h"
#import "SuggestFriend.h"

@protocol PagedUserScrollViewDelegate <NSObject>
@optional
- (void)userClicked:(SuggestFriend *)suggestedUser;
@end


@interface PagedUserScrollView : PagedScrollView <ScrollUserDelegate>

@property (nonatomic, weak) id<PagedUserScrollViewDelegate> delegate;
-(void)setSuggestedUsers:(NSArray *)users;


@end
