//
//  PagedFbUserScrollView.m
//  Frenvent
//
//  Created by minh thao nguyen on 11/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedFbUserScrollView.h"
#import "SuggestFriend.h"
#import "ScrollFbUser.h"

@implementation PagedFbUserScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setSuggestedUsers:(NSArray *)users {
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    [self.loadingSpinner stopAnimating];
    
    CGSize scrollViewSize = self.frame.size;
    self.contentSize = CGSizeMake(scrollViewSize.width * [users count], scrollViewSize.height);
    for (int i = 0; i < [users count]; i++) {
        SuggestFriend *user = [users objectAtIndex:i];
        CGRect userFrame = CGRectMake(scrollViewSize.width * i + 3 , 1, scrollViewSize.width - 6, scrollViewSize.height - 2);
        
        ScrollFbUser *userView = [[ScrollFbUser alloc] initWithFrame:userFrame];
        userView.delegate = self;
        [userView setSuggestedUser:user];
        [self addSubview:userView];
    }
}

-(void)userClicked:(SuggestFriend *)suggestedUser {
    [self.delegate userClicked:suggestedUser];
}

-(void)hiButtonClicked:(SuggestFriend *)suggestedUser {
    [self.delegate hiButtonClicked:suggestedUser];
}

@end

