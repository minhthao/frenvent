//
//  FriendManager.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/8/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *indexedFriends;
@property (nonatomic, strong) NSMutableArray *sectionTitles;

- (void) setFriends:(NSArray *)friends;
- (NSMutableArray *) getSectionedFriendsList:(NSString *)categoryChar;
- (NSArray *) getCharacterIndices;

@end
