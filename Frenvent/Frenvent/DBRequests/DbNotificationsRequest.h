//
//  This class will do nothing atm. DON'T WORRY ABOUT THIS
//

#import <Foundation/Foundation.h>

@protocol DbNotificationsRequestDelegate <NSObject>
@optional
- (void)notifyNotificationInitialized;
@end

@interface DbNotificationsRequest : NSObject
//- (void) initializeNotifications;
//- (void) uploadNotification;
@end
