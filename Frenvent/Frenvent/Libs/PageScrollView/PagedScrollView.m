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
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.pageIndicatorTintColor = [UIColor clearColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor clearColor];
        self.pageControl.hidesForSinglePage = YES;
        [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)setDefaults {
    self.pageControl.pageIndicatorTintColor = [UIColor clearColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor clearColor];
    self.pageControl.hidesForSinglePage = YES;
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pageControlIsChangingPage) return;
    self.pageControl.currentPage = [self getCurrentPage:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControlIsChangingPage = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.pageControlIsChangingPage = NO;
}

#pragma mark - change the page
- (void)changePage:(UIPageControl *)sender {
    CGRect frame = self.frame;
    frame.origin.x = self.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.frame.size;
    [self scrollRectToVisible:frame animated:YES];
    self.pageControlIsChangingPage = YES;
}

- (int)getCurrentPage:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    //switch page at 50% across
    return floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)changeToPage:(int)page {
    CGRect frame = self.frame;
    self.pageControl.currentPage = page;
    frame.origin.x = self.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.frame.size;
    [self scrollRectToVisible:frame animated:NO];
    self.pageControlIsChangingPage = YES;

}

@end
