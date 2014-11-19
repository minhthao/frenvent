//
//  EventMemberView.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/6/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"

@protocol EventParticipantViewDelegate <NSObject>
@optional
- (void)participantClick:(NSString *)uid;
@end

@interface EventParticipantView : UIView

@property (nonatomic, weak) id<EventParticipantViewDelegate> delegate;

-(void)setEventPartipant:(Friend *)friend;

@end
