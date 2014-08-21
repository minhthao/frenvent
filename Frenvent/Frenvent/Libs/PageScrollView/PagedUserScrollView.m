//
//  PagedUserScrollView.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/31/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedUserScrollView.h"
#import "SuggestFriend.h"
#import "ScrollUser.h"

@implementation PagedUserScrollView

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
    if ([users count] > 0) {
        self.contentSize = CGSizeMake(scrollViewSize.width * [users count], scrollViewSize.height);
        for (int i = 0; i < [users count]; i++) {
            SuggestFriend *user = [users objectAtIndex:i];
            CGRect userFrame = CGRectMake(scrollViewSize.width * i + 3, 1, scrollViewSize.width - 6, scrollViewSize.height - 2);

            ScrollUser *userView = [[ScrollUser alloc] initWithFrame:userFrame];
            userView.delegate = self;
            [userView setSuggestedUser:user];
            [self addSubview:userView];
        }
    } else {
        self.contentSize = scrollViewSize;
        
        UIImageView *defaultEmptyImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scrollViewSize.width, scrollViewSize.height)];
        [defaultEmptyImage setImage:[UIImage imageNamed:@"PagedEventScrollViewNoUser"]];
        [defaultEmptyImage setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:defaultEmptyImage];
        
    }
}

-(void)userClicked:(SuggestFriend *)suggestedUser {
    [self.delegate userClicked:suggestedUser];
}

@end
