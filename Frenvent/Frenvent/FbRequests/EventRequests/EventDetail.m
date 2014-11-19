//
//  EventDetail.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventDetail.h"
#import "TimeSupport.h"
#import "Event.h"
#import "EventCoreData.h"
#import "Friend.h"

@implementation EventDetail


-(void)addToCoreData {
    if ([EventCoreData getEventWithEid:self.eid] == nil) {
        [EventCoreData addEventUsingEid:self.eid
                                   name:self.name
                                picture:self.picture
                                  cover:self.cover
                              startTime:self.startTime
                                endTime:self.endTime
                               location:self.location
                              longitude:self.longitude
                               latitude:self.latitude
                                   host:self.host
                                privacy:self.privacy
                          numInterested:self.attendingCount + self.unsureCount
                                   rsvp:RSVP_NOT_INVITED];
    }
}

-(NSString *)getEventDisplayTime {
    return [TimeSupport getFullDisplayDateTime:self.startTime :self.endTime];
}

-(NSString *)getDisplayRsvp {
    if ([self.rsvp isEqualToString:RSVP_ATTENDING]) {
        if ([TimeSupport getCurrentTimeInUnix] > self.startTime) return @"Attended";
        else return @"Attending";
    } else if ([self.rsvp isEqualToString:RSVP_UNSURE]) {
        return @"Maybe";
    } else if ([self.rsvp isEqualToString:RSVP_DECLINED]) {
        return @"Declined";
    } return nil;
}

-(NSString *)getEventPrivacy {
    if ([self.privacy isEqualToString:PRIVACY_OPEN]) return @"Public event";
    else if ([self.privacy isEqualToString:PRIVACY_FRIENDS]) return @"Social event";
    else return @"Private event";
}

-(NSString *)getDisplayPrivacyAndRsvp {
    if ([self getDisplayRsvp] != nil)
        return [NSString stringWithFormat:@"%@ ∙ %@", [self getEventPrivacy], [self getDisplayRsvp]];
    else return [self getEventPrivacy];
}

-(NSAttributedString *)getFriendsInterested {
    Friend *friend = [self.attendingFriends objectAtIndex:0];
    
    NSMutableAttributedString *friendInterested = [[NSMutableAttributedString alloc] initWithString:friend.name attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]}];
    [friendInterested appendAttributedString:[[NSAttributedString alloc] initWithString:@" is interested" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:13]}]];
    
    return friendInterested;
}

@end
