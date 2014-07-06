//
//  DONT WORRY ABOUT THIS CLASS, DO NOTHING ATM
//

#import "DbNotificationsRequest.h"
#import "DBConstants.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "Notification.h"


@interface DbNotificationsRequest()

- (NSMutableURLRequest *) prepareInitializeNotificationRequest;
//- (void) processNotifications:(NSArray *)notifications;
//- (void) processInvitedEventNotification:(NSDictionary *)notification;
//- (void) processFriendEventNotification:(NSDictionary *)notification;
//- (void) processDailyEventAttendanceNotification:(NSDictionary *)notification;

@end

@implementation DbNotificationsRequest

#pragma mark - private methods
/**
 * Prepare the necessary initialization request for notifications
 * @return NS mutable URL request
 */
- (NSMutableURLRequest *) prepareInitializeNotificationRequest {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [defaults stringForKey:FB_LOGIN_USER_ID];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:uid forKey:USER_UID];
    
    NSData* nsdata = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSMutableString* jsonString =[[NSMutableString alloc] initWithData:nsdata encoding:NSASCIIStringEncoding];
    
    CFStringRef originalString = (__bridge CFStringRef)jsonString;
    
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,originalString, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
    
    
    NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",REQUEST_TYPE,REQUEST_TYPE_GET,REQUEST_DATA_TYPE, REQUEST_DATA_TYPE_NOTIFICATION, REQUEST_DATA, encodedString];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

/**
 * Process the notifications returned from our server
 * @param Array of Notification
 */
- (void) processNotifications:(NSArray *)notifications {
    for (NSDictionary *notification in notifications) {
        int16_t type = [notification[NOTIFICATION_TYPE] shortValue];
        if (type == TYPE_NEW_INVITE) {
            
        } else if (type == TYPE_FRIEND_EVENT) {
            
        };
    }
}


@end
