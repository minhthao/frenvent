//
//  PagedUserScrollView.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/31/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedScrollView.h"
#import "ScrollUser.h"

@protocol PagedUserScrollViewDelegate <NSObject>
@optional
- (void)userClicked:(NSString *)uid;
@end


@interface PagedUserScrollView : PagedScrollView <ScrollUserDelegate>

@property (nonatomic, weak) id<PagedUserScrollViewDelegate> delegate;
-(void)setSuggestedUsers:(NSArray *)users;


@end
