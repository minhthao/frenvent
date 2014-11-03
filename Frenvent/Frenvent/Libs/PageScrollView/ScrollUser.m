//
//  ScrollUser.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/31/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "ScrollUser.h"
#import "SuggestFriend.h"
#import "MyColor.h"
#import "Event.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface ScrollUser()
@property (nonatomic, strong) UIImageView *profilePicture;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *mutualFriend;
@property (nonatomic, strong) SuggestFriend *user;
@end

@implementation ScrollUser

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:2.0];
        
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTap:)];
        [self setUserInteractionEnabled:true];
        [self addGestureRecognizer:userTap];
        
        self.profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.profilePicture setClipsToBounds:YES];
        [self.profilePicture setContentMode:UIViewContentModeScaleAspectFill];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, frame.size.height - 100, frame.size.width, 100);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.95] CGColor], nil];
        [self.profilePicture.layer insertSublayer:gradient atIndex:0];
        [self addSubview:self.profilePicture];
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(20, frame.size.height - 50, frame.size.width - 90, 22)];
        [self.name setFont:[UIFont fontWithName:@"SourceSansPro-Bold" size:18]];
        [self.name setTextColor:[UIColor whiteColor]];
        [self addSubview:self.name];
        
        self.mutualFriend = [[UILabel alloc] initWithFrame:CGRectMake(20, frame.size.height - 28, frame.size.width - 90, 18)];
        [self.mutualFriend setFont:[UIFont fontWithName:@"SourceSansPro-Regular" size:14]];
        [self.mutualFriend setTextColor:[UIColor whiteColor]];
        [self addSubview:self.mutualFriend];
    }
    return self;
}

-(void)setSuggestedUser:(SuggestFriend *)user {
    self.user = user;
    
    NSString *profileUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=512&height=512", user.uid];
    [self.profilePicture sd_setImageWithURL:[NSURL URLWithString:profileUrl]];
    
    self.name.text = user.name;
    
    if (user.numMutualFriends == 1) self.mutualFriend.text = [NSString stringWithFormat:@"%d friend in common", user.numMutualFriends];
    else if (user.numMutualFriends != 0) self.mutualFriend.text = [NSString stringWithFormat:@"%d friends in common", user.numMutualFriends];
}

-(void)handleUserTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate userClicked:self.user];
}

@end
