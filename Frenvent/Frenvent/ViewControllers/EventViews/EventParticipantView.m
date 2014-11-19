//
//  EventMemberView.m
//  Frenvent
//
//  Created by minh thao nguyen on 8/6/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventParticipantView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Event.h"

@interface EventParticipantView()

@property (nonatomic, strong) UIImageView *profilePicture;

@property (nonatomic, strong) NSString *uid;

@end

@implementation EventParticipantView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTap:)];
        [self setUserInteractionEnabled:true];
        [self addGestureRecognizer:userTap];
        
        self.profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.profilePicture];
    }
    return self;
}

-(void)setEventPartipant:(Friend *)participant {
    self.uid = participant.uid;
    NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=100&height=100", participant.uid];
    [self.profilePicture setImageWithURL:[NSURL URLWithString:url]];
}

-(void)handleUserTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate participantClick:self.uid];
}

@end
