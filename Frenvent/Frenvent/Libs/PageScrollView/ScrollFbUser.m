//
//  ScrollFbUser.m
//  Frenvent
//
//  Created by minh thao nguyen on 11/10/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "ScrollFbUser.h"
#import "SuggestFriend.h"
#import "MyColor.h"
#import "Event.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ScrollFbUser()
@property (nonatomic, strong) UIImageView *cover;
@property (nonatomic, strong) UIImageView *profilePicture;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *quote;
@property (nonatomic, strong) UIButton *sayHiButton;
@property (nonatomic, strong) SuggestFriend *user;
@end

@implementation ScrollFbUser

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:2.0];
        
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTap:)];
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:userTap];
        
        self.cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 75)];
        self.cover.clipsToBounds = YES;
        self.cover.contentMode = UIViewContentModeScaleAspectFill;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, frame.size.width, frame.size.height - 75);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:255/255.0 green:128/255.0 blue:65/255.0 alpha:0.8] CGColor], (id)[[UIColor colorWithRed:255/255.0 green:128/255.0 blue:65/255.0 alpha:0.8] CGColor], nil];
        [self.cover.layer insertSublayer:gradient atIndex:0];
        [self addSubview:self.cover];
        
        self.profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(10, frame.size.height - 138, 75, 75)];
        self.profilePicture.clipsToBounds = YES;
        [self.profilePicture setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:self.profilePicture];
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(100, frame.size.height - 97, frame.size.width - 120, 20)];
        self.name.textAlignment = NSTextAlignmentLeft;
        [self.name setFont:[UIFont fontWithName:@"SourceSansPro-Bold" size:16]];
        [self.name setTextColor:[UIColor whiteColor]];
        [self addSubview:self.name];
        
        self.sayHiButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 60, frame.size.height - 75, 60, 75)];
        self.sayHiButton.titleLabel.text = @"";
        [self.sayHiButton setBackgroundImage:[UIImage imageNamed:@"ScrollViewFbUserSayHiButton"] forState:UIControlStateNormal];
        [self.sayHiButton setUserInteractionEnabled:YES];
        [self.sayHiButton addTarget:self action:@selector(handleSayHiButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sayHiButton];
        
        
        self.quote = [[UILabel alloc] init];
        self.quote.numberOfLines = 0;
        self.quote.text = [self pickupQuote];
        self.quote.font = [UIFont fontWithName:@"SourceSansPro-Light" size:13];
        self.quote.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
        CGFloat quoteHeight = [self.quote sizeThatFits:CGSizeMake(frame.size.width - 75, FLT_MAX)].height;
        self.quote.frame = CGRectMake(10, frame.size.height - 53, frame.size.width - 75, quoteHeight);
        [self addSubview:self.quote];
    }
    return self;
}

-(void)setSuggestedUser:(SuggestFriend *)user {
    self.user = user;
    
    NSString *profileUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=150&height=150", user.uid];
    [self.profilePicture setImageWithURL:[NSURL URLWithString:profileUrl]];
    if ([user.cover length] > 0) [self.cover setImageWithURL:[NSURL URLWithString:user.cover]];
    self.name.text = user.name;
    
}

-(void)handleUserTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate userClicked:self.user];
}

-(void)handleSayHiButtonTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate hiButtonClicked:self.user];
}

/**
 * A simple function that will returned a random pick up quote
 * @return NSString
 */
-(NSString *)pickupQuote {
    NSMutableArray *quoteArrays = [[NSMutableArray alloc] init];
    [quoteArrays addObject:@"“The first step is you have to say that you like.”"];
    [quoteArrays addObject:@"“Setting goals is the first step in turning the invisible into the visible.”"];
    [quoteArrays addObject:@"“The first step toward any meaningful relationship is awareness.”"];
    [quoteArrays addObject:@"“Faith is taking the first step even when you don't see the whole staircase.”"];
    [quoteArrays addObject:@"“A journey of a thousand miles begins with a single step.”"];
    [quoteArrays addObject:@"“Trust is the first step to friendship.”"];
    [quoteArrays addObject:@"“The vision must be followed by venture.”"];
    [quoteArrays addObject:@"“It is not enough to stare up the steps - step up the stairs!”"];
    [quoteArrays addObject:@"“The difference between a hero and a coward is one step sideways.”"];
    [quoteArrays addObject:@"“Everything starts with one step, or one brick, or one word or one day.”"];
    return (NSString *)[quoteArrays objectAtIndex:(rand() % [quoteArrays count])];
}

@end

