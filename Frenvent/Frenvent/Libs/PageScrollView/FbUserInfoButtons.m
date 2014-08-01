//
//  FbUserInfoButtons.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/30/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FbUserInfoButtons.h"

@implementation FbUserInfoButtons

- (void)handleProfileButtonTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate profileButtonTap];
}

- (void)handleMessageButtonTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate messageButtonTap];
}

- (void)handlePhotoButtonTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate photoButtonTap];
}

- (void)handleFriendButtonTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate friendButtonTap];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:true];
        
        //with 4 buttons, we will have 3 separator, which is of size 10. the remaining will devide equally into 4
        float viewWidth = (frame.size.width - 30)/4;
        float viewHeight = frame.size.height;
        //the view heigh is 62, with the image 47 and label 15
        UIView *profileView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        [self formatView:profileView withImageName:@"FbUserProfileIcon" andTitle:@"Profile" withSelector:@selector(handleProfileButtonTap:)];
        [self addSubview:profileView];
        
        UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(viewWidth + 10, 0, viewWidth, viewHeight)];
        [self formatView:messageView withImageName:@"FbUserMessageIcon" andTitle:@"Message" withSelector:@selector(handleMessageButtonTap:)];
        [self addSubview:messageView];
        
        UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(2 * viewWidth + 20, 0, viewWidth, viewHeight)];
        [self formatView:photoView withImageName:@"FbUserPhotoIcon" andTitle:@"Photo" withSelector:@selector(handlePhotoButtonTap:)];
        [self addSubview:photoView];
        
        UIView *friendView = [[UIView alloc] initWithFrame:CGRectMake(3 * viewWidth + 30, 0, viewWidth, viewHeight)];
        [self formatView:friendView withImageName:@"FbUserFriendIcon" andTitle:@"Friend" withSelector:@selector(handleFriendButtonTap:)];
        [self addSubview:friendView];
    }
    return self;
}

//Format the view by adding the image, title and touch selector
- (void)formatView:(UIView *)view withImageName:(NSString *)imageName andTitle:(NSString *)title withSelector:(SEL)selector{
    [view setUserInteractionEnabled:true];
    [view setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];
    [view.layer setCornerRadius:3.0f];
    [view.layer setMasksToBounds:YES];
    [view.layer setBorderWidth:2.5f];
    [view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    UILabel *buttonTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 16, view.frame.size.width, 14)];
    [buttonTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12]];
    [buttonTitle setTextColor:[UIColor lightGrayColor]];
    [buttonTitle setBackgroundColor:[UIColor clearColor]];
    [buttonTitle setTextAlignment:NSTextAlignmentCenter];
    [buttonTitle setText:title];
    [view addSubview:buttonTitle];
    
    UIImageView *buttonIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - 16)];
    [buttonIcon setContentMode:UIViewContentModeScaleToFill];
    [buttonIcon setImage:[UIImage imageNamed:imageName]];
    [view addSubview:buttonIcon];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [view addGestureRecognizer:gestureRecognizer];
}

@end
