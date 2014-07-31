//
//  PagedPhotoScrollView.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/29/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "PagedScrollView.h"
#import "ScrollImage.h"

@protocol PagedPhotoScrollViewDelegate <NSObject>
@optional
- (void)imageIndexClicked:(int)index;
@end

@interface PagedPhotoScrollView : PagedScrollView <ScrollImageDelegate>

@property (nonatomic, weak) id <PagedPhotoScrollViewDelegate> delegate;
- (void)setScrollViewPhotoUrls:(NSArray *)urls withContentModeFit:(BOOL)contentModeFit;
@end
