//
//  DbUserRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DbUserRequest : NSObject
- (BOOL) registerUser:(NSString *)uid :(NSString *)username :(NSInteger)numFriendEvents :(NSInteger)numUserEvents;
- (void) updateUserNumFriendEvents:(NSString *)uid :(NSInteger)numFriendEvents;
- (void) updateUserNumMyEvents:(NSString *)uid :(NSInteger)numMyEvents;
@end
