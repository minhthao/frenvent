//
//  Event.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "Event.h"
#import "Friend.h"
#import "TimeSupport.h"

NSString * const RSVP_ATTENDING = @"attending";
NSString * const RSVP_UNSURE = @"unsure";
NSString * const RSVP_DECLINED = @"declined";
NSString * const RSVP_NOT_REPLIED = @"not_replied";
NSString * const RSVP_NOT_INVITED = @"not_invited";

NSString * const PRIVACY_OPEN = @"OPEN";
NSString * const PRIVACY_FRIENDS = @"FRIENDS";
NSString * const PRIVACY_SECRET = @"SECRET";

static double const METER_IN_MILE = 1609.344;

@interface Event()

- (NSDictionary *) getAttributesForStringWithFont:(NSString *)fontName andSize:(NSInteger)fontSize;
- (NSString *) getTheShortenNameOfFriend:(Friend *)friend;

@end

@implementation Event

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
@dynamic friendsInterested;

@synthesize distance;

#pragma mark - private methods
/**
 * Get the attributes by font name and font size
 * For reference, there are all the font name we will be using
 *      "HelveticaNeue-Bold",
 *      "HelveticaNeue-CondensedBlack",
 *      "HelveticaNeue-Medium",
 *      "HelveticaNeue",
 *      "HelveticaNeue-Light",
 *      "HelveticaNeue-CondensedBold",
 *      "HelveticaNeue-LightItalic",
 *      "HelveticaNeue-UltraLightItalic",
 *      "HelveticaNeue-UltraLight",
 *      "HelveticaNeue-BoldItalic",
 *      "HelveticaNeue-Italic",
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
    return ([self canShare] || [self.privacy isEqualToString:PRIVACY_SECRET]);
}

/**
 * Check whether you can share the event
 * There events that allow sharing must be either 'friends of guests' event or 'public' event
 * @return boolean
 */
- (BOOL)canShare {
    return ([self.privacy isEqualToString:PRIVACY_FRIENDS] || [self.privacy isEqualToString:PRIVACY_OPEN]);
}

#pragma mark - distance
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
        NSDictionary *italicStringAttributes = [self getAttributesForStringWithFont:@"HelveticaNeue-BoldItalic" andSize:14];
        NSDictionary *normalStringAttributes = [self getAttributesForStringWithFont:@"HelveticaNeue" andSize:14];
        
        //we get the first name of your friend
        NSString *firstFriendName = [self getTheShortenNameOfFriend:[interestedFriends objectAtIndex:0]];
        NSAttributedString *firstFriendAttributedString = [[NSAttributedString alloc] initWithString:firstFriendName attributes:italicStringAttributes];
        
        [finalString appendAttributedString:firstFriendAttributedString];
        
        if ([interestedFriends count] == 1) {
            //if only one of your friends is interested in this event
            NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" is interested" attributes:normalStringAttributes];
            [finalString appendAttributedString:statement];
        } else {
            //now we add in the word ' and ' to separate the two indicators
            NSAttributedString *andConjunction = [[NSAttributedString alloc] initWithString:@" and " attributes:normalStringAttributes];
            [finalString appendAttributedString:andConjunction];

            if ([interestedFriends count] == 2) {
                //if two of your friends are interested in this event
                NSString *secondFriendName = [self getTheShortenNameOfFriend:[interestedFriends objectAtIndex:1]];
                NSAttributedString *secondFriendAttributedString = [[NSAttributedString alloc] initWithString:secondFriendName attributes:italicStringAttributes];
                [finalString appendAttributedString:secondFriendAttributedString];
                
                //add the final statement
                NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" are interested" attributes:normalStringAttributes];
                [finalString appendAttributedString:statement];
            } else {
                //add the number of other friends also interested
                NSString *numOtherFriends = [NSString stringWithFormat:@"%lu", [interestedFriends count] - 1];
                NSAttributedString *numOtherFriendsString = [[NSAttributedString alloc] initWithString:numOtherFriends attributes:italicStringAttributes];
                [finalString appendAttributedString:numOtherFriendsString];
                
                //add the final statement
                NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" others are interested" attributes:normalStringAttributes];
                [finalString appendAttributedString:statement];
            }
        }
        return finalString;
    }
}

/**
 * Get rsvp attributed string
 * @return attributed string
 */
- (NSAttributedString *) getRsvpAttributedString {
    NSDictionary *rsvpStringAttributes = [self getAttributesForStringWithFont:@"HelveticaNeue-BoldItalic" andSize:13];
    
    if ([self.rsvp isEqualToString:RSVP_ATTENDING])
       return [[NSAttributedString alloc] initWithString:@"JOINED" attributes:rsvpStringAttributes];
    
    if ([self.rsvp isEqualToString:RSVP_UNSURE])
        return [[NSAttributedString alloc] initWithString:@"MAYBE" attributes:rsvpStringAttributes];
        
    if ([self.rsvp isEqualToString:RSVP_DECLINED])
        return [[NSAttributedString alloc] initWithString:@"DECLINED" attributes:rsvpStringAttributes];
    
    return nil;
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
        NSDictionary *italicStringAttributes = [self getAttributesForStringWithFont:@"HelveticaNeue-Italic" andSize:13];
        NSDictionary *normalStringAttributes = [self getAttributesForStringWithFont:@"HelveticaNeue" andSize:13];
        
        NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
        [finalString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Host: " attributes:normalStringAttributes]];
        [finalString appendAttributedString:[[NSAttributedString alloc] initWithString:self.host attributes:italicStringAttributes]];
        return finalString;
    }
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
        if (eDistance >= 10 && eDistance < 1000) return [NSString stringWithFormat:@"%d mi.", (int)eDistance];
        else if (eDistance >= 1000) return @"1k+ mi.";
        else return [NSString stringWithFormat:@"%.1g mi.", eDistance];
    }
}


@end
