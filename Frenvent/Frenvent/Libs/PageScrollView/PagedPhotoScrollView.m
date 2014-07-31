//
//  PagedPhotoScrollView.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedPhotoScrollView.h"
#import "ScrollImage.h"

@implementation PagedPhotoScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setScrollViewPhotoUrls:(NSArray *)urls withContentModeFit:(BOOL)contentModeFit{
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    CGSize scrollViewSize = self.frame.size;
    self.contentSize = CGSizeMake(scrollViewSize.width * [urls count], scrollViewSize.height);
    for (int i = 0; i < [urls count]; i++) {
        CGRect imageFrame = CGRectMake(scrollViewSize.width * i, 0, scrollViewSize.width, scrollViewSize.height);
        ScrollImage *imageView = [[ScrollImage alloc] initWithFrame:imageFrame];
        if (contentModeFit) [imageView setImageAspectFit];
        imageView.delegate = self;
        [imageView setPageIndex:i+1 pageCount:(int)[urls count]];
        [imageView setImageUrl:[urls objectAtIndex:i]];
        [self addSubview:imageView];
    }
    self.pageControl.numberOfPages = [urls count];
}

-(void)imageIndexClicked:(int)index {
    [self.delegate imageIndexClicked:index];
}

@end
