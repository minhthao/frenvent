//
//  MyColor.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/10/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyColor : UIColor

//create a ui image from either a color or a string
+ (UIImage *) imageWithColor:(UIColor *)color;
+ (UIImage *) imageWithName:(NSString *)name;

//for event cells button
+ (UIColor *) eventCellButtonsContainerBorderColor;
+ (UIColor *) eventCellButtonNormalBackgroundColor;
+ (UIColor *) eventCellButtonHighlightBackgroundColor;
+ (UIColor *) eventCellButtonNormalTextColor;
+ (UIColor *) eventCellButtonHighlightTextColor;

@end
