//
//  EventButton.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/10/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventButton.h"
#import "MyColor.h"

@implementation EventButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //implement later
    }
    return self;
}


/**
 * Set the button title
 * @param String title
 */
- (void) setButtonTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
}

///**
// * Set the color for the title on highlight state
// * @param color
// */
//- (void) setHighlightTitleColor:(UIColor *)color {
//    [self setTitleColor:color forState:UIControlStateHighlighted];
//}
//
///**
// * Set the color for the title on normal state
// * @param color
// */
//- (void) setNormalTitleColor:(UIColor *)color {
//    [self setTitleColor:color forState:UIControlStateNormal];
//}
//
///**
// * Set the image for the button on the highlight state {
// * @param image
// */
//- (void) setHighlightImage:(UIImage *)image {
//    [self setImage:image forState:UIControlStateHighlighted];
//}
//
//- (void) setNormalImage:(UIImage *)image;
//- (void) setHighlightBackgroundColor:(UIColor *)color;
//- (void) setNormalBackgroundColor:(UIColor *)color;

@end
