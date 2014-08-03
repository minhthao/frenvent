//
//  DBConstants.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "DBConstants.h"

NSString * const APP_LINK_HOST = @"http://FreventServer-6kvbkxqtmm.elasticbeanstalk.com/AppLinkHost";
NSString * const URL = @"http://FreventServer-6kvbkxqtmm.elasticbeanstalk.com/MainServlet";

NSString * const USER_TABLE_NAME = @"user";
NSString * const USER_UID = @"uid";
NSString * const USER_USERNAME = @"username";
NSString * const USER_NUM_USER_EVENTS = @"numEvents";
NSString * const USER_NUM_FRIENDS_EVENTS = @"numFriendsEvent";
NSString * const USER_TIMESTAMP = @"timestamp";

NSString * const FBUSER_TABLE_NAME = @"fbuser";
NSString * const FBUSER_UID = @"uid";
NSString * const FBUSER_NAME = @"name";
NSString * const FBUSER_INFO = @"info";

NSString * const EVENT_TABLE_NAME = @"event";
NSString * const EVENT_EID = @"eid";
NSString * const EVENT_NAME = @"name";
NSString * const EVENT_PICTURE = @"picture";
NSString * const EVENT_START_TIME = @"start_time";
NSString * const EVENT_END_TIME = @"end_time";
NSString * const EVENT_PRIVACY = @"privacy";
NSString * const EVENT_LOCATION = @"location";
NSString * const EVENT_LONGITUDE = @"longitude";
NSString * const EVENT_LATITUDE = @"latitude";
NSString * const EVENT_NUM_INTERESTS = @"num_interest";
NSString * const EVENT_TIMESTAMP = @"timestamp";
NSString * const EVENT_DISTANCE = @"distance";
NSString * const EVENT_HOST = @"host";

NSString * const PUBLIC_EVENT_TIME_FRAME_BEGIN = @"begin";
NSString * const PUBLIC_EVENT_TIME_FRAME_END = @"end";
NSString * const PUBLIC_EVENT_LOWER_LONGITUDE = @"lower_long";
NSString * const PUBLIC_EVENT_UPPER_LONGITUDE = @"upper_long";
NSString * const PUBLIC_EVENT_LOWER_LATITUDE = @"lower_latitude";
NSString * const PUBLIC_EVENT_UPPER_LATITUDE = @"upper_latitude";

NSString * const NOTIFICATION_UID = @"uid";
NSString * const NOTIFICATION_TYPE = @"type";
NSString * const NOTIFICATION_MESSAGE = @"message";
NSString * const NOTIFICATION_MESSAGE_EXTRA1 = @"message_extra1";
NSString * const NOTIFICATION_MESSAGE_EXTRA2 = @"message_extra2";
NSString * const NOTIFICATION_EXTRA_INFO = @"extra_info";
NSString * const NOTIFICATION_VIEWED = @"viewed";
NSString * const NOTIFICATION_TIME = @"time";

// database connection constants
NSString * const REQUEST_TYPE = @"type";
NSString * const REQUEST_TYPE_POST = @"POST";
NSString * const REQUEST_TYPE_GET = @"GET";
NSString * const REQUEST_TYPE_UPDATE = @"UPDATE";
NSString * const REQUEST_TYPE_DELETE = @"DELETE";

NSString * const REQUEST_DATA_TYPE = @"data_type";
NSString * const REQUEST_DATA_TYPE_USER = @"user";
NSString * const REQUEST_DATA_TYPE_FBUSER = @"fbuser";
NSString * const REQUEST_DATA_TYPE_EVENT = @"event";
NSString * const REQUEST_DATA_TYPE_NOTIFICATION = @"notification";

NSString * const REQUEST_DATA = @"data";
NSString * const REQUEST_UPDATE_TYPE = @"update_type";
NSString * const REQUEST_UPDATE_TYPE_USER_MY_EVENT = @"user_event";
NSString * const REQUEST_UPDATE_TYPE_USER_FRIEND_EVENT = @"friend_event";

NSString * const RESPONSE_DATA = @"data";


@implementation DBConstants

@end
