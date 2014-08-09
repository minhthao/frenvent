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
#import "EventParticipant.h"

@implementation NotificationManager

-(void)initialize {
    //we first group the notifications
    NSMutableOrderedSet *friendsTodayNotifications = [[NSMutableOrderedSet alloc] init];
    self.todayNotification = [[NSMutableArray alloc] init];
    
    NSMutableOrderedSet *friendsThisWeekNotifications = [[NSMutableOrderedSet alloc] init];
    self.thisWeekNotification = [[NSMutableArray alloc] init];
    
    self.othersNotification = [[NSMutableArray alloc] init];

    NSArray *notifications = [NotificationCoreData getNotifications];
    for (Notification *notification in notifications) {
        if ([notification.time longLongValue] > [TimeSupport getTodayTimeFrameStartTimeInUnix]) {
            [friendsTodayNotifications addObject:notification.friend.uid];
            NSUInteger indexOfFriend = [friendsTodayNotifications indexOfObject:notification.friend.uid];
            if ([self.todayNotification count] > indexOfFriend) {
                [((NotificationGroup *)[self.todayNotification objectAtIndex:indexOfFriend]).events addObject:notification.event];
            } else if ([self.todayNotification count] == indexOfFriend) {
                NotificationGroup *notificationGroup = [[NotificationGroup alloc] init];
                notificationGroup.time = [notification.time longLongValue];
                notificationGroup.events = [NSMutableArray arrayWithObjects:notification.event, nil];
                notificationGroup.friend = notification.friend;
                [self.todayNotification addObject:notificationGroup];
            }
        } else if ([notification.time longLongValue] > [TimeSupport getThisWeekTimeFrameStartTimeInUnix]) {
            [friendsThisWeekNotifications addObject:notification.friend.uid];
            NSUInteger indexOfFriend = [friendsThisWeekNotifications indexOfObject:notification.friend.uid];
            if ([self.thisWeekNotification count] > indexOfFriend) {
                [((NotificationGroup *)[self.thisWeekNotification objectAtIndex:indexOfFriend]).events addObject:notification.event];
            } else if ([self.thisWeekNotification count] == indexOfFriend) {
                NotificationGroup *notificationGroup = [[NotificationGroup alloc] init];
                notificationGroup.time = [notification.time longLongValue];
                notificationGroup.events = [NSMutableArray arrayWithObjects:notification.event, nil];
                notificationGroup.friend = notification.friend;
                [self.thisWeekNotification addObject:notificationGroup];
            }
        } else {
            [self.othersNotification addObject:notification];
        }
    }
    
    //now we get the events that happend today to see who is going out
    
    self.friendsGoingoutToday = [[NSMutableArray alloc] init];
    NSMutableSet *friends = [[NSMutableSet alloc] init];
    NSArray *todayEvents = [EventCoreData getTodayEvents];
    for (Event *event in todayEvents)
        [friends unionSet:event.friendsInterested];
    for (Friend *friend in friends) {
        EventParticipant *participant = [[EventParticipant alloc] init];
        participant.friend = friend;
        participant.rsvpStatus = @"";
        
        [self.friendsGoingoutToday addObject:participant];
    }
    
    //and finally we get all the ongoing events that you got invited to but not replied
    self.userInvitedEvents = [EventCoreData getUserUnrepliedOngoingEvents];
}

/**
 * Get number of sections if the notifications to be display in a table
 * @return numSection
 */
- (NSInteger)getNumberOfSections {
    NSInteger numSections = 0;
    if ([self.friendsGoingoutToday count] > 0 || [self.userInvitedEvents count] > 0) numSections++;
    if ([self.todayNotification count] > 0) numSections++;
    if ([self.thisWeekNotification count] > 0) numSections++;
    if ([self.othersNotification count] > 0) numSections++;
    return numSections;
}

/**
 * Check if the section index is user section
 * @param section index
 * @return boolean
 */
-(BOOL)isUserSection:(NSInteger)section {
    if (section == 0 && ([self.friendsGoingoutToday count] > 0 || [self.userInvitedEvents count] > 0))
        return true;
    else return false;
}

/**
 * Check if the section index is today notifications section
 * @param section index
 * @return boolean
 */
-(BOOL)isTodaySection:(NSInteger)section {
    if ([self.todayNotification count] > 0) {
        if (section == 0 && ![self isUserSection:section]) return true;
        else if (section == 1  && [self isUserSection:0]) return true;
    }
    
    return false;
}

/**
 * Check if the section index is this week notifications section
 * @param section index
 * @return boolean
 */
-(BOOL)isThisWeekSection:(NSInteger)section {
    if ([self.thisWeekNotification count] > 0) {
        if (section == 0 && ![self isUserSection:section] && ![self isTodaySection:section]) return true;
        else if (section == 1  && [self isUserSection:0] && ![self isTodaySection:section]) return true;
        else if (section == 1 && ![self isUserSection:0] && [self isTodaySection:0]) return true;
        else if (section == 2 && [self isUserSection:0] && [self isTodaySection:1]) return true;
    }
    
    return false;
}

/**
 * Check if the section index is others notifications section
 * @param section index
 * @return boolean
 */
-(BOOL)isOthersSection:(NSInteger)section {
    if ([self.othersNotification count] > 0 && section == ([self getNumberOfSections] - 1)) return true;
    else return false;
}

/**
 * Get the section header
 * @param section index
 * @return header title
 */
-(NSString *)getSectionTitle:(NSInteger)section {
    if ([self isUserSection:section]) return @"HIGHLIGHT";
    if ([self isTodaySection:section]) return @"TODAY";
    if ([self isThisWeekSection:section]) return @"THIS WEEK";
    if ([self isOthersSection:section]) return @"OTHERS";
    return nil;
}

/**
 * Get the number of row in section
 * @param section index
 * @return num of rows
 */
-(NSInteger)numberOfRowInSection:(NSInteger)section {
    if ([self isUserSection:section]) {
        if ([self.friendsGoingoutToday count] > 0 && [self.userInvitedEvents count] > 0) return 2;
        if ([self.friendsGoingoutToday count] > 0 || [self.userInvitedEvents count] > 0) return 1;
    }
    if ([self isTodaySection:section]) return [self.todayNotification count];
    if ([self isThisWeekSection:section]) return [self.thisWeekNotification count];
    if ([self isOthersSection:section]) return [self.othersNotification count];
    return 0;
}

/**
 * Get the attributed description string for list of friends going out today
 * @return description string
 */
-(NSAttributedString *)getDescriptionForFriendsGoingoutToday {
    NSDictionary *boldFont = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]};
    NSDictionary *mediumFont = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14]};

    NSString *firstFriendName = ((EventParticipant *)[self.friendsGoingoutToday objectAtIndex:0]).friend.name;
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:firstFriendName attributes:boldFont];
    
    if ([self.friendsGoingoutToday count] == 1) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" is going out today" attributes:mediumFont]];
    } else if ([self.friendsGoingoutToday count] == 2) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" and " attributes:mediumFont]];
        NSString *secondFriendName = ((EventParticipant *)[self.friendsGoingoutToday objectAtIndex:1]).friend.name;
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
    NSDictionary *boldFont = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]};
    NSDictionary *mediumFont = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14]};
    
    if ([self.userInvitedEvents count] > 1) {
        return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"You have %d unreplied invitations to these events", (int)[self.userInvitedEvents count]] attributes:mediumFont];
    } else return [[NSAttributedString alloc] initWithString:@"You have an unreplied invitation to the event" attributes:mediumFont];
}

/**
 * Get the attributed description string for a given notification
 * @param notification
 * @return description string
 */
-(NSAttributedString *)getDescriptionForNotification:(Notification *)notification {
    NSDictionary *boldFont = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]};
    NSDictionary *mediumFont = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14]};
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:notification.friend.name attributes:boldFont];
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" replied interested to the event" attributes:mediumFont]];
    
    return description;
}

/**
 * Get the attributed description string for a notification group
 * @param notification groups
 * @return description string
 */
-(NSAttributedString *)getDescriptionForNotificationGroup:(NotificationGroup *)notificationGroup {
    NSDictionary *boldFont = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]};
    NSDictionary *mediumFont = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14]};
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:notificationGroup.friend.name attributes:boldFont];

    if ([notificationGroup.events count] > 1) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" replied interested to " attributes:mediumFont]];
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)[notificationGroup.events count]] attributes:boldFont]];
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" events" attributes:mediumFont]];
    } else if ([notificationGroup.events count] == 1) {
        [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" replied interested to the event" attributes:mediumFont]];
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
    UIApplication *frenvent = [UIApplication sharedApplication];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"%@ is interested in %@", notification.friend.name, [notification.event.name capitalizedString]];
    localNotification.alertAction = @"Slide to unlock";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = frenvent.applicationIconBadgeNumber + 1;
    
    [frenvent presentLocalNotificationNow:localNotification];
}

@end
