//
//  Event.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/14/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "Event.h"
#import "Friend.h"
#import "Notification.h"
#import "TimeSupport.h"

NSString * const RSVP_ATTENDING = @"attending";
NSString * const RSVP_UNSURE = @"unsure";
NSString * const RSVP_DECLINED = @"declined";
NSString * const RSVP_NOT_REPLIED = @"not_replied";
NSString * const RSVP_NOT_INVITED = @"not_invited";

NSString * const PRIVACY_OPEN = @"OPEN";
NSString * const PRIVACY_FRIENDS = @"FRIENDS";
NSString * const PRIVACY_SECRET = @"SECRET";

int32_t const MARK_TYPE_NORMAL = 0;
int32_t const MARK_TYPE_FAVORITE = 1;
int32_t const MARK_TYPE_HIDDEN = 2;

static double const METER_IN_MILE = 1609.344;

@implementation Event

@dynamic cover;
@dynamic eid;
@dynamic endTime;
@dynamic host;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic name;
@dynamic numInterested;
@dynamic picture;
@dynamic privacy;
@dynamic rsvp;
@dynamic startTime;
@dynamic markType;
@dynamic friendsInterested;
@dynamic notifications;

@synthesize distance;
@synthesize score;

#pragma mark - private methods
/**
 * Get the attributes by font name and font size
 * @param font name
 * @param font size
 * @return dictionary of attributes
 */
- (NSDictionary *) getAttributesForStringWithFont:(NSString *)fontName andSize:(NSInteger)fontSize{
    return @{NSFontAttributeName: [UIFont fontWithName:fontName size:fontSize]};
}

/**
 * Get the shorten name of your friend
 * @param friend
 * @return String
 */
- (NSString *) getTheShortenNameOfFriend:(Friend *)friend {
    NSArray *wordsAndEmptyStrings = [friend.name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    return [words objectAtIndex:0];
}

#pragma mark - check whether you can rsvp and/or share
/**
 * Check whether you can make a rsvp to the event
 * These events that allow rsvp typically have the display predefined rsvp above
 * @return boolean
 */
- (BOOL)canRsvp {
    return ([self canShare] || [self.privacy isEqualToString:PRIVACY_SECRET] || ![self.rsvp isEqualToString:RSVP_NOT_INVITED]);
}

/**
 * Check whether you can share the event
 * There events that allow sharing must be either 'friends of guests' event or 'public' event
 * @return boolean
 */
- (BOOL)canShare {
    return ([self.privacy isEqualToString:PRIVACY_FRIENDS] || [self.privacy isEqualToString:PRIVACY_OPEN]);
}

#pragma mark - compute distance and score
/**
 * Given a location, compute the distance between the event and this location
 * @param CLLocation
 */
- (void)computeDistanceToCurrentLocation:(CLLocation *)currentLocation {
    if (self.longitude != nil && [self.longitude doubleValue] != 0 &&
        self.latitude != nil && [self.latitude doubleValue] != 0) {
        CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
        CLLocationDistance distanceInMeters = [eventLocation distanceFromLocation:currentLocation];
        
        self.distance = [NSNumber numberWithDouble:distanceInMeters/METER_IN_MILE];
    }
}

#pragma mark - attributed string methods

/**
 * Get the displayable attributed string for the friends that are interested in event
 * @return Attributed string
 */
- (NSAttributedString *) getFriendsInterestedAttributedString {
    if (self.friendsInterested == nil || [self.friendsInterested count] == 0) {
        return nil;
    } else {
        NSArray *interestedFriends = [self.friendsInterested allObjects];
        NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
        
        //create attributes for the string that we are going to use
        NSDictionary *boldStringAttributes = [self getAttributesForStringWithFont:@"SourceSansPro-Semibold" andSize:14];
        NSDictionary *normalStringAttributes = [self getAttributesForStringWithFont:@"SourceSansPro-Regular" andSize:14];
        
        NSAttributedString *firstFriendAttributedString = [[NSAttributedString alloc] initWithString:((Friend *)[interestedFriends objectAtIndex:0]).name attributes:boldStringAttributes];
        
        if ([interestedFriends count] == 1) {
            //statement
            NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" is interested" attributes:normalStringAttributes];
            
            [finalString appendAttributedString:firstFriendAttributedString];
            [finalString appendAttributedString:statement];
        } else if ([interestedFriends count] == 2){
            //and conjunction
            NSAttributedString *andConjunction = [[NSAttributedString alloc] initWithString:@" and " attributes:normalStringAttributes];
            
            //name of second friend
             NSAttributedString *secondFriendAttributedString = [[NSAttributedString alloc] initWithString:((Friend *)[interestedFriends objectAtIndex:1]).name attributes:boldStringAttributes];
            
            //add the final statement
            NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" are interested" attributes:normalStringAttributes];
            
            [finalString appendAttributedString:firstFriendAttributedString];
            [finalString appendAttributedString:andConjunction];
            [finalString appendAttributedString:secondFriendAttributedString];
            [finalString appendAttributedString:statement];
        } else {
            //we iterate through the loop to find a favorite friend if exist;
            for (Friend *friend in interestedFriends) {
                if ([friend.favorite boolValue]) {
                    firstFriendAttributedString = [[NSAttributedString alloc] initWithString:friend.name attributes:boldStringAttributes];
                    break;
                }
            }
            
            //and conjunction
            NSAttributedString *andConjunction = [[NSAttributedString alloc] initWithString:@" and " attributes:normalStringAttributes];
                
            //add the number of other friends also interested
            NSString *numOtherFriends = [NSString stringWithFormat:@"%ld", (long)([interestedFriends count] - 1)];
            NSAttributedString *numOtherFriendsString = [[NSAttributedString alloc] initWithString:numOtherFriends attributes:boldStringAttributes];
            
            //add the final statement
            NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" others are interested" attributes:normalStringAttributes];
            
            [finalString appendAttributedString:firstFriendAttributedString];
            [finalString appendAttributedString:andConjunction];
            [finalString appendAttributedString:numOtherFriendsString];
            [finalString appendAttributedString:statement];
        }
        return finalString;
    }
}

/**
 * Get rsvp attributed string
 * @return attributed string
 */
- (NSAttributedString *) getRsvpAttributedString {
    NSDictionary *rsvpStringAttributes = [self getAttributesForStringWithFont:@"SourceSansPro-Semibold" andSize:14];
    
    if ([self.rsvp isEqualToString:RSVP_ATTENDING])
        return [[NSAttributedString alloc] initWithString:@"Joined" attributes:rsvpStringAttributes];
    
    if ([self.rsvp isEqualToString:RSVP_UNSURE])
        return [[NSAttributedString alloc] initWithString:@"Maybe" attributes:rsvpStringAttributes];
    
    if ([self.rsvp isEqualToString:RSVP_DECLINED])
        return [[NSAttributedString alloc] initWithString:@"Declined" attributes:rsvpStringAttributes];
    
    return nil;
}

/**
 * Get the rsvp and people attending
 * @return attributed string
 */
- (NSAttributedString *) getRsvpAndAttendeesAttributedString {
    NSDictionary *rsvpStringAttributes = [self getAttributesForStringWithFont:@"SourceSansPro-Semibold" andSize:14];
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    [finalString appendAttributedString:[self getRsvpAttributedString]];
    if ([self getFriendsInterestedAttributedString] != nil) {
        [finalString appendAttributedString:[[NSAttributedString alloc] initWithString:@" - " attributes:rsvpStringAttributes]];
        [finalString appendAttributedString:[self getFriendsInterestedAttributedString]];
    }
        
    return finalString;
}

/**
 * Get the host attributed string
 * @return attributed string
 */
- (NSAttributedString *) getHostAttributedString {
    if (self.host == nil || [self.host length] ==0) {
        return nil;
    } else {
        //create attributes for the string that we are going to use
        NSDictionary *hostStringAttributes = [self getAttributesForStringWithFont:@"SourceSansPro-Semibold" andSize:14];
        NSString *hostString = [NSString stringWithFormat:@"Host: %@", self.host];
        
        return [[NSAttributedString alloc] initWithString:hostString attributes:hostStringAttributes];
    }
}

/**
 * Get from event name attributed string
 * @return attributed string
 */
- (NSAttributedString *) getFromEventNameAttributedString {
    NSDictionary *boldStringAttributes = [self getAttributesForStringWithFont:@"SourceSansPro-Semibold" andSize:14];
    NSDictionary *normalStringAttributes = [self getAttributesForStringWithFont:@"SourceSansPro-Regular" andSize:14];
    
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:@"Meet me at " attributes:normalStringAttributes];
    [name appendAttributedString:[[NSAttributedString alloc ] initWithString:self.name attributes:boldStringAttributes]];
    return name;
}

/**
 * Get the distance string
 * @return string
 */
- (NSString *)getDistanceString {
    if (self.distance == nil || [self.distance doubleValue] == 0) {
        return @"N/A";
    } else {
        double eDistance = [self.distance doubleValue];
        if (eDistance >= 10 && eDistance < 1000) return [NSString stringWithFormat:@"%d mil", (int)eDistance];
        else if (eDistance >= 1000) return @"1k+ mil";
        else return [NSString stringWithFormat:@"%.1f mil", eDistance];
    }
}


@end
