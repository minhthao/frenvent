//
//  FriendManager.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/8/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendManager.h"
#import "Friend.h"

@interface FriendManager()

- (BOOL) isNumeric:(NSString *)character;
- (BOOL) isAlphabet:(NSString *)character;

@end

@implementation FriendManager

#pragma mark - private methods
/**
 * Check if a character is of numeric type (0-9)
 * @param String with 1 character
 * @return boolean
 */
- (BOOL) isNumeric:(NSString *)character {
    return ([character isEqualToString:@"0"] || [character isEqualToString:@"1"] || [character isEqualToString:@"2"] ||
            [character isEqualToString:@"3"] || [character isEqualToString:@"4"] || [character isEqualToString:@"5"] ||
            [character isEqualToString:@"6"] || [character isEqualToString:@"7"] || [character isEqualToString:@"8"] ||
            [character isEqualToString:@"9"]);
}

/**
 * Check if a character is of alphabet type (A-Z)
 * @param String with 1 character
 * @return boolean
 */
- (BOOL)isAlphabet:(NSString *)character {
    unichar indexChar = [character characterAtIndex:0];
    return (indexChar >= 'A' && indexChar <= 'Z');
}

#pragma mark - public methods
- (void) setFriends:(NSArray *)friends {
    if (_indexedFriends == nil) _indexedFriends = [[NSMutableDictionary alloc] init];
    else [_indexedFriends removeAllObjects];
    
    if (_sectionTitles == nil) _sectionTitles = [[NSMutableArray alloc] init];
    else [_sectionTitles removeAllObjects];
    
    //now we partion the friends object info indexes
    for (int i = 0; i < [friends count]; i++) {
        Friend *friend = [friends objectAtIndex:i];
        
        NSString *firstLetter = [[friend.name substringToIndex:1] uppercaseString];
        
        //if friend name start with numeric characters
        if ([self isNumeric:firstLetter]) {
            NSMutableArray *numericFriends = [_indexedFriends objectForKey:@"#"];
            if (numericFriends == nil) {
                numericFriends = [[NSMutableArray alloc] init];
                [_indexedFriends setObject:numericFriends forKey:@"#"];
            }
            [numericFriends addObject:friend];
        } else if ([self isAlphabet:firstLetter]) {
            
            //if friend name start with alphabet characters
            NSMutableArray *alphabetFriends = [_indexedFriends objectForKey:firstLetter];
            if (alphabetFriends == nil) {
                alphabetFriends = [[NSMutableArray alloc] init];
                [_indexedFriends setObject:alphabetFriends forKey:firstLetter];
            }
            [alphabetFriends addObject:friend];
        } else {
            
            //if friend name start with some character outside the alphabet
            NSMutableArray *specialCharFriends = [_indexedFriends objectForKey:firstLetter];
            if (specialCharFriends == nil) {
                specialCharFriends = [[NSMutableArray alloc] init];
                [_indexedFriends setObject:specialCharFriends forKey:@"@"];
            }
            [specialCharFriends addObject:friend];
        }
    }
    
    //finally get the array of titles
    NSArray *charIndices = [self getCharacterIndices];
    for (int i = 0; i < [charIndices count]; i++) {
        NSString *indexChar = [charIndices objectAtIndex:i];
        if (_indexedFriends[indexChar] != nil) {
            [_sectionTitles addObject:indexChar];
        }
    }
    
}

- (NSMutableArray *) getSectionedFriendsList:(NSString *)categoryChar {
    return [_indexedFriends objectForKey:categoryChar];
}


- (NSArray *) getCharacterIndices {
    return @[@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"@"];
}

@end
