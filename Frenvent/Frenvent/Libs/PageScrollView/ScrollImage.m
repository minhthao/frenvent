//
//  ScrollImage.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/25/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "ScrollImage.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface ScrollImage()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic) int index;
@end

@implementation ScrollImage

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
        [self setUserInteractionEnabled:true];
        [self addGestureRecognizer:imageTap];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.clipsToBounds = true;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor =[UIColor whiteColor];
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.shadowColor = [UIColor blackColor];
        self.label.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:self.label];

    }
    return self;
}

-(void)setImageAspectFit {
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)setImageUrl:(NSString *)url {
    [self.imageView setImageWithURL:[NSURL URLWithString:url] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
}

-(void)setPageIndex:(int)index pageCount:(int)pageCount {
    self.index = index - 1; //the indexx start at 1
    if (pageCount == 1) self.label.text = @"";
    else self.label.text = [NSString stringWithFormat:@"%d of %d", index, pageCount];
}

-(void)handleImageTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate imageIndexClicked:self.index];
}


@end
