//
//  NotificationManager.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/14/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "NotificationManager.h"
#import "NotificationCoreData.h"
#import "EventCoreData.h"
#import "Notification.h"
#import "NotificationGroup.h"
#import "TimeSupport.h"
#import "Event.h"
#import "Friend.h"
#import "DBNotificationRequest.h"
#import "FriendCoreData.h"

@interface NotificationManager()

@property (nonatomic) int64_t todayStartTime;
@property (nonatomic) int64_t thisWeekStartTime;

@end

@implementation NotificationManager

@synthesize recommendUsers;

-(id)init {
    self = [super init];
    if (self) {
        self.todayStartTime = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    }
    return self;
}

-(void)initialize {
    //we first group the notifications
    NSMutableOrderedSet *friendActivitiesNotification = [[NSMutableOrderedSet alloc] init];
    self.friendActivities = [[NSMutableArray alloc] init];

    NSArray *notifications = [NotificationCoreData getNotifications];
    for (Notification *notification in notifications) {
        if ([notification.friend.favorite boolValue]) {
            [friendActivitiesNotification addObject:notification.friend.uid];
            NSUInteger indexOfFriend = [friendActivitiesNotification indexOfObject:notification.friend.uid];
            if ([self.friendActivities count] > indexOfFriend) {
                [((NotificationGroup *)[self.friendActivities objectAtIndex:indexOfFriend]).events addObject:notification.event];
            } else if ([self.friendActivities count] == indexOfFriend) {
                NotificationGroup *notificationGroup = [[NotificationGroup alloc] init];
                notificationGroup.time = [notification.time longLongValue];
                notificationGroup.events = [NSMutableArray arrayWithObjects:notification.event, nil];
                notificationGroup.friend = notification.friend;
                [self.friendActivities addObject:notificationGroup];
            }
        }
    }
    
    //now we get the events that happend today to see who is going out
    
    self.friendsGoingoutToday = [[NSMutableArray alloc] init];
    NSMutableSet *friends = [[NSMutableSet alloc] init];
    NSArray *todayEvents = [EventCoreData getTodayEvents];
    for (Event *event in todayEvents)
        [friends unionSet:event.friendsInterested];
    for (Friend *friend in friends) {
        [self.friendsGoingoutToday addObject:friend];
    }
    
    //and finally we get all the ongoing events that you got invited to but not replied
    self.userInvitedEvents = [EventCoreData getUserUnrepliedOngoingEvents];
}

-(void)reset {
    self.todayStartTime = [TimeSupport getTodayTimeFrameStartTimeInUnix];
    self.thisWeekStartTime = [TimeSupport getThisWeekTimeFrameStartTimeInUnix];
    [self initialize];
}

/**
 * Get number of sections if the notifications to be display in a table
 * @return numSection
 */
- (NSInteger)getNumberOfSections {
    NSInteger numSections = 0;
    if (self.recommendUsers != nil && [self.recommendUsers count] > 0) numSections ++;
    if ([self.friendsGoingoutToday count] > 0 || [self.userInvitedEvents count] > 0) numSections++;
    if ([self.friendActivities count] > 0) numSections++;
    return numSections;
}

/**
 * Check if the section index is the recommend user section
 * @param section index
 * @return boolean
 */
-(BOOL)isRecommendUsersSection:(NSInteger)section {
    return (section == 0 && self.recommendUsers != nil && [self.recommendUsers count] > 0);
}

/**
 * Check if the section index is user section
 * @param section index
 * @return boolean
 */
-(BOOL)isUserSection:(NSInteger)section {
    if ([self.friendsGoingoutToday count] > 0 || [self.userInvitedEvents count] > 0) {
        if ([self isRecommendUsersSection:0]) return section == 1;
        else return section == 0;
    }
    return false;
}

/**
 * Check if the section index is friends activities section
 * @param section index
 * @return boolean
 */
-(BOOL)isFriendActivitySection:(NSInteger)section {
    return !([self isRecommendUsersSection:section] || [self isUserSection:section]);
}

/**
 * Get the section header
 * @param section index
 * @return header title
 */
-(NSString *)getSectionTitle:(NSInteger)section {
    if ([self isRecommendUsersSection:section]) return @"Friends to meet today";
    if ([self isUserSection:section]) return @"Highlights";
    if ([self isFriendActivitySection:section]) return @"Friend activities";
    return nil;
}

/**
 * Get the number of row in section
 * @param section index
 * @return num of rows
 */
-(NSInteger)numberOfRowInSection:(NSInteger)section {
    if ([self isRecommendUsersSection:section]) return 1;
    if ([self isUserSection:section]) {
        if ([self.friendsGoingoutToday count] > 0 && [self.userInvitedEvents count] > 0) return 2;
        if ([self.friendsGoingoutToday count] > 0 || [self.userInvitedEvents count] > 0) return 1;
    }
    if ([self isFriendActivitySection:section]) return [self.friendActivities count];
    return 0;
}

/**
 * Get the attributed description string for list of friends going out today
 * @return description string
 */
-(NSAttributedString *)getDescriptionForFriendsGoingoutToday {
    NSDictionary *boldFont = @{NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Semibold" size:14]};
    NSDictionary *mediumFont = @{NSFontAttributeName: [UIFont fontWithName:@"SourceSansPro-Regular" size:14]};

    NSString *firstFriendName = ((Friend *)[self.friendsGoingoutToday objectAtIndex:0]).name;
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:firstFriendName attributes:boldFont];
    
    if ([self.friendsGoingoutToday count] == 1) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" is going out today" attributes:mediumFont]];
    } else if ([self.friendsGoingoutToday count] == 2) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" and " attributes:mediumFont]];
        NSString *secondFriendName = ((Friend *)[self.friendsGoingoutToday objectAtIndex:1]).name;
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:secondFriendName attributes:boldFont]];
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" are going out today" attributes:mediumFont]];
    } else if ([self.friendsGoingoutToday count] > 2) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" and " attributes:mediumFont]];
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)([self.friendsGoingoutToday count] - 1)] attributes:boldFont]];
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" others are going out today" attributes:mediumFont]];
    }
    return description;
}

/**
 * Get the attributed description string for list of events you got invited to
 * @return description string
 */
-(NSAttributedString *)getDescriptionForInvitedEvents {
    NSDictionary *mediumFont = @{NSFontAttributeName: [UIFont fontWithName:@"SourceSansPro-Regular" size:14]};
    
    if ([self.userInvitedEvents count] > 1) {
        return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"You have %d unreplied invitations to these events", (int)[self.userInvitedEvents count]] attributes:mediumFont];
    } else return [[NSAttributedString alloc] initWithString:@"You have an unreplied invitation to the event" attributes:mediumFont];
}

/**
 * Get the attributed description string for a notification group
 * @param notification groups
 * @return description string
 */
-(NSAttributedString *)getDescriptionForNotificationGroup:(NotificationGroup *)notificationGroup {
    NSDictionary *boldFont = @{NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Semibold" size:14]};
    NSDictionary *mediumFont = @{NSFontAttributeName: [UIFont fontWithName:@"SourceSansPro-Regular" size:14]};
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:notificationGroup.friend.name attributes:boldFont];

    if ([notificationGroup.events count] > 1) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" is interested in " attributes:mediumFont]];
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)[notificationGroup.events count]] attributes:boldFont]];
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" events" attributes:mediumFont]];
    } else if ([notificationGroup.events count] == 1) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" is interested in the event" attributes:mediumFont]];
    }
    
    return description;
}


/**
 * Create and display new invited notification
 * @param notification
 */
+ (void)createNotificationForInviteEvent:(Event *)event {
    UIApplication *frenvent = [UIApplication sharedApplication];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"You got invited to %@", [event.name capitalizedString]];
    localNotification.alertAction = @"Slide to unlock";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = frenvent.applicationIconBadgeNumber + 1;
    
    [frenvent presentLocalNotificationNow:localNotification];
    frenvent.applicationIconBadgeNumber++;
}

/**
 * Create and display new friend notification
 * @param notification
 */
+ (void)createNewFriendNotification:(Notification *)notification {
    [DBNotificationRequest addNotificationForFriend:notification.friend.uid andEvent:notification.event.eid andStartTime:[notification.event.startTime longLongValue]];
    
    if ([notification.friend.favorite boolValue] == true) {
        UIApplication *frenvent = [UIApplication sharedApplication];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ is interested in %@", notification.friend.name, [notification.event.name capitalizedString]];
        localNotification.alertAction = @"Slide to unlock";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = frenvent.applicationIconBadgeNumber + 1;
        
        [frenvent presentLocalNotificationNow:localNotification];
    }
}

@end
