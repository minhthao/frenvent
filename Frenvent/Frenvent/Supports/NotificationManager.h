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
@property (nonatomic, strong) NSMutableArray *todayNotification;
@property (nonatomic, strong) NSMutableArray *thisWeekNotification;
@property (nonatomic, strong) NSMutableArray *othersNotification;

-(void)initialize;
-(NSInteger)getNumberOfSections;
-(BOOL)isUserSection:(NSInteger)section;
-(BOOL)isTodaySection:(NSInteger)section;
-(BOOL)isThisWeekSection:(NSInteger)section;
-(BOOL)isOthersSection:(NSInteger)section;
-(NSString *)getSectionTitle:(NSInteger)section;
-(NSInteger)numberOfRowInSection:(NSInteger)section;

-(NSAttributedString *)getDescriptionForFriendsGoingoutToday;
-(NSAttributedString *)getDescriptionForInvitedEvents;

-(NSAttributedString *)getDescriptionForNotification:(Notification *)notification;
-(NSAttributedString *)getDescriptionForNotificationGroup:(NotificationGroup *)notificationGroup;


+ (void)createNotificationForInviteEvent:(Event *)event;
+ (void)createNewFriendNotification:(Notification *)notification;

@end
