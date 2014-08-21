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
@property (nonatomic, strong) UIImageView *cover;
@property (nonatomic, strong) UIImageView *profilePicture;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *mutualFriend;
@property (nonatomic, strong) SuggestFriend *user;
@end

@implementation ScrollUser

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setMasksToBounds:NO];
        [self.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
        [self.layer setShadowRadius:1];
        [self.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
        [self.layer setShadowOpacity:0.35f];
        [self.layer setBorderWidth:0.5f];
        [self.layer setBorderColor:[[MyColor eventCellButtonsContainerBorderColor] CGColor]];
        
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTap:)];
        [self setUserInteractionEnabled:true];
        [self addGestureRecognizer:userTap];
        
        self.cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.cover.clipsToBounds = true;
        self.cover.contentMode = UIViewContentModeScaleAspectFill;
        self.cover.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.cover];
        
        self.profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(8, frame.size.height - 70, 65, 65)];
        [self.profilePicture.layer setMasksToBounds:YES];
        [self.profilePicture.layer setBorderWidth:3];
        [self.profilePicture.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.profilePicture setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.profilePicture];
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(80, frame.size.height - 50, frame.size.width - 90, 25)];
        [self.name setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:24]];
        [self.name setTextColor:[UIColor whiteColor]];
        [self.name setBackgroundColor:[UIColor clearColor]];
        [self.name setTextAlignment:NSTextAlignmentLeft];
        self.name.shadowColor = [UIColor blackColor];
        self.name.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:self.name];
        
        self.mutualFriend = [[UILabel alloc] initWithFrame:CGRectMake(80, frame.size.height - 25, frame.size.width - 90, 20)];
        [self.mutualFriend setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
        [self.mutualFriend setTextColor:[UIColor whiteColor]];
        [self.mutualFriend setBackgroundColor:[UIColor clearColor]];
        [self.mutualFriend setTextAlignment:NSTextAlignmentLeft];
        self.mutualFriend.shadowColor = [UIColor blackColor];
        self.mutualFriend.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:self.mutualFriend];
    }
    return self;
}

-(void)setSuggestedUser:(SuggestFriend *)user {
    self.user = user;
    if ([user.cover length] > 0)
        [self.cover setImageWithURL:[NSURL URLWithString:user.cover] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    else [self.cover setImage:[MyColor imageWithColor:[UIColor grayColor]]];
    
    NSString *profileUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", user.uid];
    [self.profilePicture sd_setImageWithURL:[NSURL URLWithString:profileUrl]];
    
    self.name.text = user.name;
    
    if (user.numMutualFriends != 0) {
        if ([user.rsvpStatus isEqualToString:RSVP_ATTENDING]) self.mutualFriend.text = [NSString stringWithFormat:@"Attending ∙ %d mutual friends", user.numMutualFriends];
        else if ([user.rsvpStatus isEqualToString:RSVP_UNSURE]) self.mutualFriend.text = [NSString stringWithFormat:@"Maybe ∙ %d mutual friends", user.numMutualFriends];
        else self.mutualFriend.text = [NSString stringWithFormat:@"%d mutual friends", user.numMutualFriends];
    } else {
        if ([user.rsvpStatus isEqualToString:RSVP_ATTENDING]) self.mutualFriend.text = @"Attending";
        else if ([user.rsvpStatus isEqualToString:RSVP_UNSURE]) self.mutualFriend.text = @"Maybe";
    }
}

-(void)handleUserTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate userClicked:self.user];
}

@end
