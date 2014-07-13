//
//  MyColor.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/10/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "MyColor.h"

@implementation MyColor

//get the ui image from ui color
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//get the ui image using the provided image name. The image should have png extension
+ (UIImage *) imageWithName:(NSString *)name {
    NSMutableString *fullImageName = [[NSMutableString alloc] init];
    [fullImageName appendString:name];
    if ([UIScreen mainScreen].scale == 2) [fullImageName appendString:@"@2x"];
    
    return [UIImage imageNamed:fullImageName];
}

#pragma mark - Color for event cell button background and text
//buttons container border color
+ (UIColor *) eventCellButtonsContainerBorderColor {
    return [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
}

//normal background
+ (UIColor *) eventCellButtonNormalBackgroundColor {
    return [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

//highlight background
+ (UIColor *) eventCellButtonHighlightBackgroundColor {
    return [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
}

//normal text
+ (UIColor *) eventCellButtonNormalTextColor {
    return [UIColor colorWithRed:67/255.0 green:74/255.0 blue:135/255.0 alpha:1.0];
}

//highlight text
+ (UIColor *) eventCellButtonHighlightTextColor {
    return [UIColor darkGrayColor];
}

@end
