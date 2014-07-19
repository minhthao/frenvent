//
//  Notification.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/14/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "Notification.h"
#import "Event.h"
#import "Friend.h"

NSInteger const TYPE_NEW_INVITE = 9;
NSInteger const TYPE_FRIEND_EVENT = 5;

@implementation Notification

@dynamic time;
@dynamic type;
@dynamic event;
@dynamic friends;

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

#pragma mark - main method
/**
 * Get the attributed string for friends replied interested in the events
 * @return NSAttributedString
 */
- (NSAttributedString *)getFriendsRepliedInterestedAttributedString {
    if (self.friends == nil || [self.friends count] == 0) {
        return nil;
    } else {
        NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
        
        //create attributes for the string that we are going to use
        NSDictionary *boldStringAttributes = [self getAttributesForStringWithFont:@"HelveticaNeue-Bold" andSize:14];
        NSDictionary *normalStringAttributes = [self getAttributesForStringWithFont:@"HelveticaNeue" andSize:14];
        
        //we get the first name of your friend
        NSString *firstFriendName = [self getTheShortenNameOfFriend:[self.friends objectAtIndex:0]];
        NSAttributedString *firstFriendAttributedString = [[NSAttributedString alloc] initWithString:firstFriendName attributes:boldStringAttributes];
        
        [finalString appendAttributedString:firstFriendAttributedString];
        
        if ([self.friends count] == 1) {
            //if only one of your friends is interested in this event
            NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" replied interested to event" attributes:normalStringAttributes];
            [finalString appendAttributedString:statement];
        } else {
            //now we add in the word ' and ' to separate the two indicators
            NSAttributedString *andConjunction = [[NSAttributedString alloc] initWithString:@" and " attributes:normalStringAttributes];
            [finalString appendAttributedString:andConjunction];
            if ([self.friends count] == 2) {
                //now we add in the word ' and ' to separate the two indicators
                NSAttributedString *andConjunction = [[NSAttributedString alloc] initWithString:@" and " attributes:normalStringAttributes];
                [finalString appendAttributedString:andConjunction];
                
                //if two of your friends are interested in this event
                NSString *secondFriendName = [self getTheShortenNameOfFriend:[self.friends objectAtIndex:1]];
                NSAttributedString *secondFriendAttributedString = [[NSAttributedString alloc] initWithString:secondFriendName attributes:boldStringAttributes];
                [finalString appendAttributedString:secondFriendAttributedString];
                
                //add the final statement
                NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" replied interested to event" attributes:normalStringAttributes];
                [finalString appendAttributedString:statement];
            } else {
                //now we add in the word ' and ' to separate the two indicators
                NSAttributedString *commaConjunction = [[NSAttributedString alloc] initWithString:@", " attributes:normalStringAttributes];
                [finalString appendAttributedString:commaConjunction];
                
                //if two of your friends are interested in this event
                NSString *secondFriendName = [self getTheShortenNameOfFriend:[self.friends objectAtIndex:1]];
                NSAttributedString *secondFriendAttributedString = [[NSAttributedString alloc] initWithString:secondFriendName attributes:boldStringAttributes];
                [finalString appendAttributedString:secondFriendAttributedString];
                
                NSAttributedString *andConjunction = [[NSAttributedString alloc] initWithString:@" and " attributes:normalStringAttributes];
                [finalString appendAttributedString:andConjunction];
                
                //add the number of other friends also interested
                NSString *numOtherFriends = [NSString stringWithFormat:@"%ld", (long)([self.friends count] - 2)];
                NSAttributedString *numOtherFriendsString = [[NSAttributedString alloc] initWithString:numOtherFriends attributes:boldStringAttributes];
                [finalString appendAttributedString:numOtherFriendsString];
                
                //add the final statement
                NSAttributedString *statement = [[NSAttributedString alloc] initWithString:@" others replied interested to event" attributes:normalStringAttributes];
                [finalString appendAttributedString:statement];
            }
        }
        return finalString;
    }
}

@end
