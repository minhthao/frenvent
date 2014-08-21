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
    }
    return self;
}

- (void)setScrollViewPhotoUrls:(NSArray *)urls withContentModeFit:(BOOL)contentModeFit{
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    [self.loadingSpinner stopAnimating];
    
    CGSize scrollViewSize = self.frame.size;
    
    if ([urls count] > 0) {
        self.contentSize = CGSizeMake(scrollViewSize.width * [urls count], scrollViewSize.height);
        for (int i = 0; i < [urls count]; i++) {
            CGRect imageFrame = CGRectMake(scrollViewSize.width * i + 3, 1, scrollViewSize.width - 6, scrollViewSize.height - 2);
            if (contentModeFit) imageFrame = CGRectMake(scrollViewSize.width * i, 0, scrollViewSize.width, scrollViewSize.height);
            
            ScrollImage *imageView = [[ScrollImage alloc] initWithFrame:imageFrame];
            if (contentModeFit) [imageView setImageAspectFit];
            if (!self.shouldShowImageIndex) [imageView hidePageIndex];
            imageView.delegate = self;
            [imageView setPageIndex:i+1 pageCount:(int)[urls count]];
            [imageView setImageUrl:[urls objectAtIndex:i]];
            [self addSubview:imageView];
        }
    } else {
        self.contentSize = scrollViewSize;
        
        UIImageView *defaultEmptyImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scrollViewSize.width, scrollViewSize.height)];
        [defaultEmptyImage setImage:[UIImage imageNamed:@"PagedEventScrollViewNoPhoto"]];
        [defaultEmptyImage setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:defaultEmptyImage];
    }
}

-(void)imageIndexClicked:(int)index {
    [self.delegate imageIndexClicked:index];
}

@end
