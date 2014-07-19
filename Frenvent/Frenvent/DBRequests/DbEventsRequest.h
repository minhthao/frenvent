//
//  DbEventsRequests.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/2/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DbEventsRequestDelegate <NSObject>
- (void)notifyEventRequestFailure;
@optional
- (void)notifyEventsUploaded;
- (void)notifyEventsUploaded:(BOOL)successfullyUploaded WithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)notifyNearbyEventsInitialized;
- (void)notifyNearbyEventsRefreshedWithResults:(NSArray *)events;
@end

@interface DbEventsRequest : NSObject
@property (nonatomic, weak) id <DbEventsRequestDelegate> delegate;
- (void) uploadEvents:(NSArray *)events;
- (void) uploadEvents:(NSArray *)events withCompletitionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void) initNearbyEvents:(double)currentLocLongitude :(double)currentLocLatitude;
- (void) refreshNearbyEvents:(double)lowerLong :(double)lowerLat :(double)upperLong :(double)upperLat;
@end
