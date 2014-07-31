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
+ (NSArray *) getEvents:(NSPredicate *)predicates sortByDateAsc:(BOOL)isAsc{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:context];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:isAsc selector:nil];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sort, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setSortDescriptors:sortDescriptors];

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
    
    NSPredicate *markTypeNormalPredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_NORMAL];
    NSPredicate *markTypeFavoritePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_FAVORITE];
    NSPredicate *markType = [NSCompoundPredicate orPredicateWithSubpredicates:@[markTypeFavoritePredicate, markTypeNormalPredicate]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, rsvpPredicate, markType]];
    
    return [self getEvents:predicates sortByDateAsc:false];
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
    
    NSPredicate *markTypeNormalPredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_NORMAL];
    NSPredicate *markTypeFavoritePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_FAVORITE];
    NSPredicate *markType = [NSCompoundPredicate orPredicateWithSubpredicates:@[markTypeFavoritePredicate, markTypeNormalPredicate]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, rsvpPredicate, markType]];
    
    return [self getEvents:predicates sortByDateAsc:true];
}

/**
 * Get the user's ongoing events - the one which they rsvped
 * @return Array of Event
 */
+ (NSArray *) getUserRepliedOngoingEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    
    NSPredicate *attendingRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_ATTENDING];
    NSPredicate *unsureRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_UNSURE];
    NSPredicate *declinedRsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_DECLINED];
    NSPredicate *rsvpPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[attendingRsvpPredicate, unsureRsvpPredicate, declinedRsvpPredicate]];
    
    NSPredicate *markTypeNormalPredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_NORMAL];
    NSPredicate *markTypeFavoritePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_FAVORITE];
    NSPredicate *markType = [NSCompoundPredicate orPredicateWithSubpredicates:@[markTypeFavoritePredicate, markTypeNormalPredicate]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, rsvpPredicate, markType]];
    
    return [self getEvents:predicates sortByDateAsc:true];

}

/**
 * Get the user's ongoing events - the one which they had not replied
 * @return Array of Event
 */
+ (NSArray *) getUserUnrepliedOngoingEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    NSPredicate *rsvpPredicate = [NSPredicate predicateWithFormat:@"rsvp = %@", RSVP_NOT_REPLIED];
    
    NSPredicate *markTypeNormalPredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_NORMAL];
    NSPredicate *markTypeFavoritePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_FAVORITE];
    NSPredicate *markType = [NSCompoundPredicate orPredicateWithSubpredicates:@[markTypeFavoritePredicate, markTypeNormalPredicate]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, rsvpPredicate, markType]];
    
    return [self getEvents:predicates sortByDateAsc:true];

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
    NSPredicate *upperLngPredicate = [NSPredicate predicateWithFormat:@"longitude <= %f", upperLongitude];
    NSPredicate *upperLatPredicate = [NSPredicate predicateWithFormat:@"latitude <= %f", upperLatitude];
    NSPredicate *coordinatePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[longitudeExistPredicate, latitudeExistPredicate, lowerLngPredicate, lowerLatPredicate, upperLngPredicate, upperLatPredicate]];
    
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    
    NSPredicate *markTypeNormalPredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_NORMAL];
    NSPredicate *markTypeFavoritePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_FAVORITE];
    NSPredicate *markType = [NSCompoundPredicate orPredicateWithSubpredicates:@[markTypeFavoritePredicate, markTypeNormalPredicate]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[coordinatePredicate, timePredicate, markType]];
    
    return [self getEvents:predicates sortByDateAsc:true];
}

/**
 * Get all the friends events
 * @return Array of Event
 */
+ (NSArray *) getFriendsEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    NSPredicate *friendsPredicate = [NSPredicate predicateWithFormat:@"friendsInterested.@count > 0"];
    
    NSPredicate *markTypeNormalPredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_NORMAL];
    NSPredicate *markTypeFavoritePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_FAVORITE];
    NSPredicate *markType = [NSCompoundPredicate orPredicateWithSubpredicates:@[markTypeFavoritePredicate, markTypeNormalPredicate]];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, friendsPredicate, markType]];
    
    return [self getEvents:predicates sortByDateAsc:true];
}

#pragma mark - filter by either name or eid
+ (NSArray *) getAllOngoingEvents {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    return [self getEvents:predicate sortByDateAsc:true];
}

/**
 * Get all the events that match the given text
 * @param name(partial) of event
 * @return Array of Event
 */
+ (NSArray *) getEventsWithMatchingName:(NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[cd] %@", name];
    return [self getEvents:predicate sortByDateAsc:true];
}

/**
 * Get the event with specific eid
 * @param eid
 * @return event
 */
+ (Event *) getEventWithEid:(NSString *)eid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eid = %@", eid];
    NSArray *result = [self getEvents:predicate sortByDateAsc:true];
    if (result.count > 0) return [result objectAtIndex:0];
    return nil;
}

#pragma mark - getting the hidden or favorite only events
/**
 * Get the ongoing hidden events
 * @return Array of event
 */
+ (NSArray *) getOngoingHiddenEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    NSPredicate *markTypePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_HIDDEN];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, markTypePredicate]];
    return [self getEvents:predicates sortByDateAsc:true];
}

/**
 * Get the ongoing favorite events
 * @return Array of Events
 */
+ (NSArray *) getOngoingFavoriteEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime >= %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    NSPredicate *markTypePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_FAVORITE];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, markTypePredicate]];
    return [self getEvents:predicates sortByDateAsc:true];
}

/**
 * Get the past favorite events
 * @return Array of Events
 */
+ (NSArray *) getPastFavoriteEvents {
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"startTime < %d", [TimeSupport getTodayTimeFrameStartTimeInUnix]];
    NSPredicate *markTypePredicate = [NSPredicate predicateWithFormat:@"markType = %d", MARK_TYPE_FAVORITE];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[timePredicate, markTypePredicate]];
    return [self getEvents:predicates sortByDateAsc:true];
}

#pragma mark - set event mark type
+ (void) setEventMarkType:(Event *)event withType:(int32_t)markType{
    event.markType = [NSNumber numberWithInt:markType];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error updating the mark type of events - error:%@", error);
}

#pragma mark - public remove methods

/**
 * Remove all events stored in the datacore
 * Typically, we should only use this on login out
 */
+ (void) removeAllEvents {
    NSArray *items = [self getEvents:nil sortByDateAsc:true];
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
    
    NSArray *items = [self getEvents:predicates sortByDateAsc:true];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    }
    
    NSError *error = nil;
    if (![context save:&error]) NSLog(@"Error deleting events - error:%@", error);
}

/**
 * Remove the event with the given eid
 * @param eid
 */
+ (void) removeEventWithEid:(NSString *)eid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eid = %@", eid];
    NSArray *items = [self getEvents:predicate sortByDateAsc:true];
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
                       cover:(NSString *)cover
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
    event.markType = [NSNumber numberWithInt:MARK_TYPE_NORMAL];
    event.eid = eid;
    event.name = name;
    event.picture =  picture;
    event.cover = cover;
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
    
    NSString *eid;
    if ([eventObj[@"eid"] isKindOfClass:[NSString class]])
        eid = eventObj[@"eid"];
    else eid = [eventObj[@"eid"] stringValue];
    
    NSString *name = eventObj[@"name"];
    
    NSString *picture = @"";
    if (eventObj[@"pic_big"] !=  nullInstance)
        picture = eventObj[@"pic_big"];
    
    NSString *cover = @"";
    if ([eventObj[@"pic_cover"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *coverDic = eventObj[@"pic_cover"];
        if (coverDic[@"source"] != nullInstance)
            cover = coverDic[@"source"];
    }
    
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
    
    return [self addEventUsingEid:eid name:name picture:picture cover:cover startTime:startTime endTime:endTime location:location longitude:longitude latitude:latitude host:host privacy:privacy numInterested:numInterested rsvp:rsvp];
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
    NSArray *result = [self getEvents:predicate sortByDateAsc:true];
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
