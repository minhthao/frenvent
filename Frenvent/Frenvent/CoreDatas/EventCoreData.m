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
#import "DBConstants.h"

@interface EventCoreData()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

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

#pragma mark - public get methods

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
+ (NSArray *) getNearbyEventsBoundedByLowerLongitude:(double)lowerLongitude
                                       lowerLatitude:(double)lowerLatitude
                                      upperLongitude:(double)upperLongitude
                                       upperLatitude:(double)upperLatitude {
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
+ (NSArray *) getEventsWithMatchingName:(NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[cd] %@", name];
    return [self getEvents:predicate];
}

/**
 * Get the event with specific eid
 * @param eid
 * @return event
 */
+ (Event *) getEventWithEid:(NSString *)eid {
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
 * @param All event fields
 * @return Event
 */
+ (Event *) addEventUsingEid:(NSString *)eid
                        name:(NSString *)name
                     picture:(NSString *)picture
                   startTime:(int64_t)startTime
                     endTime:(int64_t)endTime
                    location:(NSString *)location
                   longitude:(double)longitude
                    latitude:(double)latitude
                        host:(NSString *)host
                     privacy:(NSString *)privacy
               numInterested:(int32_t)numInterested
                        rsvp:(NSString *)rsvp {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:context];
    
    Event *event = [[Event alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    event.eid = eid;
    event.name = name;
    event.picture =  picture;
    event.startTime = [NSNumber numberWithLongLong:startTime];
    event.endTime = [NSNumber numberWithLongLong:endTime];
    event.location = location;
    event.longitude = [NSNumber numberWithDouble:longitude];
    event.latitude = [NSNumber numberWithDouble:latitude];
    event.host = host;
    event.privacy = privacy;
    event.numInterested = [NSNumber numberWithInt:numInterested];;
    event.rsvp = rsvp;

    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error adding event - error:%@", error);
    
    return event;
}

/**
 * Add an event to the core data
 * @param EventObj
 * @return Event
 */
+ (Event *) addEvent:(NSDictionary *)eventObj usingRsvp:(NSString *)rsvp {
    NSNull *nullInstance = [NSNull null];
    
    NSString *eid = [eventObj[@"eid"] stringValue];
    NSString *name = eventObj[@"name"];
    
    NSString *picture = @"";
    if (eventObj[@"pic_big"] !=  nullInstance)
        picture = eventObj[@"pic_big"];
    
    
    uint64_t startTime = [TimeSupport getUnixTime: [TimeSupport getDateTimeInStandardFormat:eventObj[@"start_time"]]];
    
    uint64_t endTime = 0;
    if (eventObj[@"end_time"] != nullInstance)
        endTime = [TimeSupport getUnixTime: [TimeSupport getDateTimeInStandardFormat:eventObj[@"end_time"]]];
    
    NSString *location = @"";
    if (eventObj[@"location"] != nullInstance)
        location = eventObj[@"location"];
    
    NSDictionary *venue = eventObj[@"venue"];
    
    double longitude = 0;
    double latitude = 0;
    if ([venue isKindOfClass:[NSDictionary class]] && venue[@"longitude"] != nil && venue[@"latitude"] != nil) {
        longitude = [venue[@"longitude"] doubleValue];
        latitude = [venue[@"latitude"] doubleValue];
    }
   
    NSString *host = @"";
    if (eventObj[@"host"] != nullInstance)
        host = eventObj[@"host"];

    NSString *privacy = @"";
    if (eventObj[@"privacy"] != nullInstance)
        privacy = eventObj[@"privacy"];

    int32_t numInterested = [eventObj[@"attending_count"] intValue] + [eventObj[@"unsure_count"] intValue];
    
    return [self addEventUsingEid:eid name:name picture:picture startTime:startTime endTime:endTime location:location longitude:longitude latitude:latitude host:host privacy:privacy numInterested:numInterested rsvp:rsvp];
}

#pragma mark - public update methods
/**
 * Update the rsvp status of the event. We do this when user make rsvp change, or
 * when the event is returned in the fb query for user's event, but it already exist in
 * our core data
 * @param eid
 * @param rsvp
 */
+ (void) updateEventWithEid:(NSString *)eid usingRsvp:(NSString *)newRsvp {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eid = %@", eid];
    NSArray *result = [self getEvents:predicate];
    if (result.count > 0) {
        Event *event = [result objectAtIndex:0];
        if (![event.rsvp isEqualToString:newRsvp]) {
            event.rsvp = newRsvp;
            NSError *error = nil;
            if (![context save:&error]) NSLog(@"Error updating event's rsvp - error:%@", error);
        }
    }
}

            

@end
