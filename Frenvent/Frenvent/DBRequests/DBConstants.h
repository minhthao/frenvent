//
//  DBConstants.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const APP_LINK_HOST;
extern NSString * const URL;

extern NSString * const USER_TABLE_NAME;
extern NSString * const USER_UID;
extern NSString * const USER_USERNAME;
extern NSString * const USER_NUM_USER_EVENTS;
extern NSString * const USER_NUM_FRIENDS_EVENTS;
extern NSString * const USER_TIMESTAMP;

extern NSString * const FBUSER_TABLE_NAME;
extern NSString * const FBUSER_UID;
extern NSString * const FBUSER_NAME;
extern NSString * const FBUSER_INFO;

extern NSString * const EVENT_TABLE_NAME;
extern NSString * const EVENT_EID;
extern NSString * const EVENT_NAME;
extern NSString * const EVENT_PICTURE;
extern NSString * const EVENT_START_TIME;
extern NSString * const EVENT_END_TIME;
extern NSString * const EVENT_PRIVACY;
extern NSString * const EVENT_LOCATION;
extern NSString * const EVENT_LONGITUDE;
extern NSString * const EVENT_LATITUDE;
extern NSString * const EVENT_NUM_INTERESTS;
extern NSString * const EVENT_TIMESTAMP;
extern NSString * const EVENT_DISTANCE;
extern NSString * const EVENT_HOST;

extern NSString * const PUBLIC_EVENT_TIME_FRAME_BEGIN;
extern NSString * const PUBLIC_EVENT_TIME_FRAME_END;
extern NSString * const PUBLIC_EVENT_LOWER_LONGITUDE;
extern NSString * const PUBLIC_EVENT_UPPER_LONGITUDE;
extern NSString * const PUBLIC_EVENT_LOWER_LATITUDE;
extern NSString * const PUBLIC_EVENT_UPPER_LATITUDE;

extern NSString * const NOTIFICATION_UID;
extern NSString * const NOTIFICATION_TYPE;
extern NSString * const NOTIFICATION_MESSAGE;
extern NSString * const NOTIFICATION_MESSAGE_EXTRA1;
extern NSString * const NOTIFICATION_MESSAGE_EXTRA2;
extern NSString * const NOTIFICATION_EXTRA_INFO;
extern NSString * const NOTIFICATION_VIEWED;
extern NSString * const NOTIFICATION_TIME;

// database connection constants
extern NSString * const REQUEST_TYPE;
extern NSString * const REQUEST_TYPE_POST;
extern NSString * const REQUEST_TYPE_GET;
extern NSString * const REQUEST_TYPE_UPDATE;
extern NSString * const REQUEST_TYPE_DELETE;

extern NSString * const REQUEST_DATA_TYPE;
extern NSString * const REQUEST_DATA_TYPE_USER;
extern NSString * const REQUEST_DATA_TYPE_FBUSER;
extern NSString * const REQUEST_DATA_TYPE_EVENT;
extern NSString * const REQUEST_DATA_TYPE_NOTIFICATION;

extern NSString * const REQUEST_DATA;

extern NSString * const REQUEST_UPDATE_TYPE;
extern NSString * const REQUEST_UPDATE_TYPE_USER_MY_EVENT;
extern NSString * const REQUEST_UPDATE_TYPE_USER_FRIEND_EVENT;

extern NSString * const RESPONSE_DATA;


@interface DBConstants : NSObject

@end
