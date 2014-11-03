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
        [self setBackgroundImage:[MyColor imageWithColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]] forState:UIControlStateNormal];
        [self setBackgroundImage:[MyColor imageWithColor:[MyColor eventCellButtonHighlightBackgroundColor]] forState:UIControlStateHighlighted];
        
        [self.titleLabel setFont:[UIFont fontWithName:@"SourceSansPro-Semibold" size:17]];
        [self setTitleColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        
        [self setUserInteractionEnabled:true];
    }
    return self;
}

@end
