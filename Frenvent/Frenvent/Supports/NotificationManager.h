//
//  NotificationManager.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/14/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"
#import "NotificationGroup.h"

@interface NotificationManager : NSObject

@property (nonatomic, strong) NSMutableArray *friendsGoingoutToday;
@property (nonatomic, strong) NSArray *userInvitedEvents;
@property (nonatomic, strong) NSMutableArray *friendActivities;
@property (nonatomic, strong) NSArray *recommendUsers;

-(void)initialize;
-(void)reset;
-(NSInteger)getNumberOfSections;
-(BOOL)isRecommendUsersSection:(NSInteger)section;
-(BOOL)isUserSection:(NSInteger)section;
-(BOOL)isFriendActivitySection:(NSInteger)section;
-(NSString *)getSectionTitle:(NSInteger)section;
-(NSInteger)numberOfRowInSection:(NSInteger)section;

-(NSAttributedString *)getDescriptionForFriendsGoingoutToday;
-(NSAttributedString *)getDescriptionForInvitedEvents;
-(NSAttributedString *)getDescriptionForNotificationGroup:(NotificationGroup *)notificationGroup;


+ (void)createNotificationForInviteEvent:(Event *)event;
+ (void)createNewFriendNotification:(Notification *)notification;

@end
