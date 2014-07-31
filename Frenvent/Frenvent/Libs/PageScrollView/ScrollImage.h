//
//  ScrollImage.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/25/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollImageDelegate <NSObject>
@optional
- (void)imageIndexClicked:(int)index ;
@end

@interface ScrollImage : UIView

@property (nonatomic, weak) id <ScrollImageDelegate> delegate;

-(void)setImageUrl:(NSString *)url;
-(void)setPageIndex:(int)index pageCount:(int)pageCount;
-(void)setImageAspectFit;
@end
