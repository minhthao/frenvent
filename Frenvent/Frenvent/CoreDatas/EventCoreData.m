//
//  EventCoreData.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/24/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventCoreData.h"
#import "AppDelegate.h"
#import "TimeSupport.h"
#import "Event.h"

@interface EventCoreData()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (NSMutableArray *) getEvents: (NSPredicate *)predicates;

@end

@implementation EventCoreData

#pragma mark - private methods
/**
 * Lazily obtain the managed object context
 * @return managed object context
 */
+ (NSManagedObjectContext *) managedObjectContext {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

/**
 * Get fetched event using the set of predicates
 * @return Array of Event
 */
+ (NSArray *) getEvents:(NSPredicate *)predicates {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    if (predicates != nil) [fetchRequest setPredicate:predicates];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:fetchRequest error:&error];
    
    if (events == nil) NSLog(@"Error get Events %@", error);
    
    return events;
}

#pragma mark - public get methods

/**
 * Get user's past events
 * @return Array of Event
 */
+ (NSArray *) getUserPastEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime < %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    
    NSPredicate *attendingRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_ATTENDING];
    NSPredicate *unsureRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_UNSURE];
    NSPredicate *declinedRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_DECLINED];
    NSPredicate *notRepliedRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_NOT_REPLIED];
    
    NSPredicate *rsvpPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[attendingRsvpPredicate, unsureRsvpPredicate, declinedRsvpPredicate, notRepliedRsvpPredicate]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, rsvpPredicate]];
    
    return [self getEvents:predicates];
}

/**
 * Get the user's ongoing events
 * @return Array of Event
 */
+ (NSArray *) getUserOngoingEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    
    NSPredicate *attendingRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_ATTENDING];
    NSPredicate *unsureRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_UNSURE];
    NSPredicate *declinedRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_DECLINED];
    NSPredicate *notRepliedRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_NOT_REPLIED];
    
    NSPredicate *rsvpPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[attendingRsvpPredicate, unsureRsvpPredicate, declinedRsvpPredicate, notRepliedRsvpPredicate]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, rsvpPredicate]];
    
    return [self getEvents:predicates];
}

/**
 * Get all the nearby events
 * @return Array of Event
 */
+ (NSArray *) getNearbyEvents:(double)lowerLongitude :(double)lowerLatitude
                             :(double)upperLongitude :(double)upperLatitude {
    NSPredicate *longitudeExistPredicate = [NSPredicate predicateWithFormat:@"longitude != %f", 0];
    NSPredicate *latitudeExistPredicate =[NSPredicate predicateWithFormat:@"latitude != %f", 0];
    
    NSPredicate *lowerLngPredicate = [NSPredicate predicateWithFormat:@"longitude >= %f", lowerLongitude];
    NSPredicate *lowerLatPredicate = [NSPredicate predicateWithFormat:@"latitude >= %f", lowerLatitude];
    NSPredicate *upperLngPredicate = [NSPredicate predicateWithFormat:@"longtidue <= %f", upperLongitude];
    NSPredicate *upperLatPredicate = [NSPredicate predicateWithFormat:@"latitude <= %f", upperLatitude];
    
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[longitudeExistPredicate, latitudeExistPredicate, lowerLngPredicate, lowerLatPredicate, upperLngPredicate, upperLatPredicate, timePredicate]];
    
    return [self getEvents:predicates];
}

/**
 * Get all the friends events
 * @return Array of Event
 */
+ (NSArray *) getFriendsEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    
    NSPredicate *friendsPredicate = [NSPredicate predicateWithFormat:@"friendsInterested.@count > 0"];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, friendsPredicate]];
    
    return [self getEvents:predicates];
}

/**
 * Get all the events that match the given text
 * @param name(partial) of event
 * @return Array of Event
 */
+ (NSArray *) getEventsWithMatchingName: (NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[cd] %@", name];
    return [self getEvents:predicate];
}

/**
 * Get the event with specific eid
 * @param eid
 * @return event
 */
+ (Event *) getEventWithEid: (NSString *)eid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eid = %@", eid];
    NSArray *result = [self getEvents:predicate];
    if (result.count > 0) return [result objectAtIndex:0];
    return nil;
}

#pragma mark - public remove methods

/**
 * Remove all events stored in the datacore
 * Typically, we should only use this on login out
 */
+ (void) removeAllEvents {
    NSArray *items = [self getEvents:nil];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting events - error:%@", error);
}

/**
 * This is the better version of the 'removeAllEvents' method
 * This method will remove only events that associate with the
 * users, such as past event or friends' events. RECOMMEND to
 * be use with logout function
 */
+ (void) removeUserAssociatedEvents {
    NSPredicate *attendingRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_ATTENDING];
    NSPredicate *unsureRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_UNSURE];
    NSPredicate *declinedRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_DECLINED];
    NSPredicate *notRepliedRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_NOT_REPLIED];
    
    NSPredicate *rsvpPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[attendingRsvpPredicate, unsureRsvpPredicate, declinedRsvpPredicate, notRepliedRsvpPredicate]];
    
    NSPredicate *friendsPredicate = [NSPredicate predicateWithFormat:@"friendsInterested.@count > 0"];
    
    NSPredicate *predicates = [NSCompoundPredicate orPredicateWithSubpredicates:@[rsvpPredicate, friendsPredicate]];
    
    NSArray *items = [self getEvents:predicates];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting events - error:%@", error);

    //TODO provide the call back to say that the process of removal has finished
}

/**
 * Remove the event with the given eid
 * @param eid
 */
+ (void) removeEventWithEid:(NSString *)eid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eid = %@", eid];
    NSArray *items = [self getEvents:predicate];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting events - error:%@", error);
}

#pragma mark - public add methods

/**
 * Add an event to the core data
 * @param Event
 */
+ (void) addEvent:(Event *)event {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context insertObject:event];
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error adding event - error:%@", error);
}

#pragma mark - public update methods
/**
 * Update the rsvp status of the event. We do this when user make rsvp change, or
 * when the event is returned in the fb query for user's event, but it already exist in
 * our core data
 * @param eid
 * @param rsvp
 */
+ (void) updateEventRsvp:(NSString *)eid :(NSString *)newRsvp {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eid = %@", eid];
    NSArray *result = [self getEvents:predicate];
    if (result.count > 0) {
        Event *event = [result objectAtIndex:0];
        if (![event.rsvp isEqualToString:newRsvp]) {
            if ([newRsvp isEqualToString: RSVP_NOT_INVITED]) {
                //TODO make appropriate notification, saying that you got invite to new event
            }
            event.rsvp = newRsvp;
            NSError *error = nil;
            if (![context save:&error]) NSLog(@"Error updating event's rsvp - error:%@", error);
        }
    }
}

            

@end
