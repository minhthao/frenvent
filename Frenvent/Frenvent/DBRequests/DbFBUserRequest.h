//
//  DbFBUserRequest.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/1/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DbFBUserRequest : NSObject

+(BOOL)addFbUserWithUid:(NSString *)uid andName:(NSString *)name;

@end