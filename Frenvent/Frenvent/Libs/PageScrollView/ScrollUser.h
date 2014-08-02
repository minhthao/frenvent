//
//  ScrollUser.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/31/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestFriend.h"

@protocol ScrollUserDelegate <NSObject>
@optional
- (void)userClicked:(SuggestFriend *)suggestedUser;
@end

@interface ScrollUser : UIView

@property (nonatomic, weak) id <ScrollUserDelegate> delegate;
-(void)setSuggestedUser:(SuggestFriend *)user;
-(void)setPageIndex:(int)index pageCount:(int)pageCount;
@end
