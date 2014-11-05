//
//  PagedScrollView.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedScrollView.h"

@interface PagedScrollView()
@property (nonatomic) BOOL pageControlIsChangingPage;
@end

@implementation PagedScrollView

#pragma mark - initiation
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentSize = CGSizeMake(self.frame.size.width , self.frame.size.height);
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = false;
        
        //add a loading spinner (size 20-by-20) at the middle of the view
        self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width - 20) / 2, (self.frame.size.height - 20) / 2, 20, 20)];
        [self.loadingSpinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.loadingSpinner setHidesWhenStopped:true];
        [self.loadingSpinner startAnimating];
        [self addSubview:self.loadingSpinner];
        
        //enable the paging
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (int)getCurrentPage:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    //switch page at 50% across
    return floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)changeToPage:(int)page {
    CGRect frame = self.frame;
    frame.origin.x = self.frame.size.width * page;
    frame.origin.y = 0;
    frame.size = self.frame.size;
    [self scrollRectToVisible:frame animated:NO];
    self.pageControlIsChangingPage = YES;
}

@end
