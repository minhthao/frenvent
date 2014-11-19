//
//  UIFont+SystemFontOverride.m
//  Frenvent
//
//  Created by minh thao nguyen on 11/12/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "UIFont+SystemFontOverride.h"

@implementation UIFont (SystemFontOverride)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"SourceSansPro-Semibold" size:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"SourceSansPro-Regular" size:fontSize];
}

#pragma clang diagnostic pop

@end
