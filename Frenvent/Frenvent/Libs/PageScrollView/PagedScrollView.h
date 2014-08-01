//
//  PagedScrollView.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagedScrollView : UIScrollView

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

-(void)changeToPage:(int)page;

@end
