//
//  EventDetailsRequest.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventDetailsRequest.h"
#import "EventDetail.h"
#import "EventParticipant.h"
#import "Event.h"
#import "FriendCoreData.h"
#import "TimeSupport.h"

static int16_t const QUERY_LIMIT = 5000;

@implementation EventDetailsRequest

/**
 * Prepare the query method parameters
 * @return dictionary
 */
- (NSDictionary *) prepareQueryParams:(NSString *)eid {
    NSString *myRsvp = [NSString stringWithFormat:@"SELECT rsvp_status FROM event_member WHERE eid = %@ AND uid = me()", eid];
    NSString *eventParticipants = [NSString stringWithFormat:@"SELECT uid, rsvp_status FROM event_member WHERE eid = %@ AND "
                                   "uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) AND "
                                   "(rsvp_status = \"attending\" OR rsvp_status = \"unsure\") LIMIT %d", eid, QUERY_LIMIT];
    NSString *eventInfo = [NSString stringWithFormat:@"SELECT name, pic_big, pic_cover, start_time, end_time, "
                           "location, venue, description, attending_count, unsure_count, not_replied_count, host, privacy "
                           "FROM event WHERE eid = %@", eid];
    
    NSString *query = [NSString stringWithFormat:@"{'myRsvp':'%@', 'eventParticipants':'%@', 'eventInfo':'%@'}",
                       myRsvp, eventParticipants, eventInfo];
    
    NSDictionary *queryParams = @{@"q": query};
    return queryParams;
}

/**
 * Public query methods. First check if we can make the query.
 * @param uid
 */
- (void) queryEventDetail:(NSString *)eid{
    if ([FBSession activeSession].isOpen &&
        [[FBSession activeSession] hasGranted:@"friends_events"] &&
        [[FBSession activeSession] hasGranted:@"user_events"] ) {
        
        [self doQueryForEventDetailWithEid:eid];
    } else if ([FBSession activeSession].state== FBSessionStateCreatedTokenLoaded) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"user_events", @"friends_events", @"friends_work_history", @"read_stream", @"friends_photos"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) [self.delegate notifyEventDetailsQueryFail];
            else if (FB_ISSESSIONOPENWITHSTATE(status)) [self doQueryForEventDetailWithEid:eid];
            else [self.delegate notifyEventDetailsQueryFail];
        }];
    } else [self.delegate notifyEventDetailsQueryFail];
}

/**
 * Execute the query for event detail
 * @param eid
 */
- (void) doQueryForEventDetailWithEid:(NSString *)eid {
    NSDictionary *queryParams = [self prepareQueryParams:eid];
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParams
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
          if (error) {
              [self.delegate notifyEventDetailsQueryFail];
          } else {
              NSNull *nullInstance = [NSNull null];

              EventDetail *eventDetail =  [[EventDetail alloc] init];
              eventDetail.eid = eid;
              
              NSArray *data = (NSArray *)result[@"data"];
              
              BOOL eventExist = true;
              
              for (int i = 0; i < [data count]; i++) {
                  NSArray *resultSet = data[i][@"fql_result_set"];
                  if ([data[i][@"name"] isEqualToString:@"myRsvp"]) {
                      //get your rsvp
                      NSString *rsvp = RSVP_NOT_INVITED;
                      if ([resultSet count] > 0)
                          rsvp = resultSet[0][@"rsvp_status"];
                      eventDetail.rsvp = rsvp;
                  } else if ([data[i][@"name"] isEqualToString:@"eventParticipants"]) {
                      //get attendees
                      NSMutableArray *participants = [[NSMutableArray alloc] init];
                      for (NSDictionary *participantDic in resultSet) {
                          EventParticipant *participant = [[EventParticipant alloc] init];
                          participant.rsvpStatus = participantDic[@"rsvp_status"];
                          NSString *uid = participantDic[@"uid"];
                          Friend *friendParticipant = [FriendCoreData getFriendWithUid:uid];
                          participant.friend = friendParticipant;
                          
                          [participants addObject:participant];
                      }
                      
                      eventDetail.attendingFriends = participants;
                  } else if ([data[i][@"name"] isEqualToString:@"eventInfo"]) {
                      if ([resultSet count] > 0) {
                          //now set all the event details information
                          NSDictionary *eventObj = resultSet[0];
                          eventDetail.name = eventObj[@"name"];
                          
                          NSString *picture = @"";
                          if (eventObj[@"pic_big"] !=  nullInstance)
                              picture = eventObj[@"pic_big"];
                          eventDetail.picture = picture;
                          
                          NSString *cover = @"";
                          if ([eventObj[@"pic_cover"] isKindOfClass:[NSDictionary class]]) {
                              NSDictionary *coverDic = eventObj[@"pic_cover"];
                              if (coverDic[@"source"] != nullInstance)
                                  cover = coverDic[@"source"];
                          }
                          eventDetail.cover = cover;
                          
                          uint64_t startTime = [TimeSupport getUnixTime: [TimeSupport getDateTimeInStandardFormat:eventObj[@"start_time"]]];
                          eventDetail.startTime = startTime;
                          
                          uint64_t endTime = 0;
                          if (eventObj[@"end_time"] != nullInstance)
                              endTime = [TimeSupport getUnixTime: [TimeSupport getDateTimeInStandardFormat:eventObj[@"end_time"]]];
                          eventDetail.endTime = endTime;
                          
                          NSString *location = @"";
                          if (eventObj[@"location"] != nullInstance)
                              location = eventObj[@"location"];
                          eventDetail.location = location;
                          
                          NSDictionary *venue = eventObj[@"venue"];
                          
                          NSString * street = @"";
                          NSString * city = @"";
                          NSString * state = @"";
                          NSString * zip = @"";
                          NSString * country = @"";
                          double longitude = 0;
                          double latitude = 0;
                          if ([venue isKindOfClass:[NSDictionary class]] && venue[@"longitude"] != nil && venue[@"latitude"] != nil) {
                              if (eventObj[@"street"] != nullInstance && eventObj[@"street"] == nil)
                                  street = eventObj[@"street"];
                              eventDetail.street = street;
                              
                              if (eventObj[@"city"] != nullInstance && eventObj[@"city"] == nil)
                                  city = eventObj[@"city"];
                              eventDetail.city = city;
                              
                              if (eventObj[@"state"] != nullInstance && eventObj[@"state"] == nil)
                                  state = eventObj[@"state"];
                              eventDetail.state = state;
                              
                              if (eventObj[@"zip"] != nullInstance && eventObj[@"zip"] == nil)
                                  zip = eventObj[@"zip"];
                              eventDetail.zip = zip;
                              
                              if (eventObj[@"country"] != nullInstance && eventObj[@"country"] == nil)
                                  country = eventObj[@"country"];
                              eventDetail.country = country;
                              
                              longitude = [venue[@"longitude"] doubleValue];
                              eventDetail.longitude = longitude;
                              
                              latitude = [venue[@"latitude"] doubleValue];
                              eventDetail.latitude = latitude;
                          }
                          
                          NSString *description = @"";
                          if (eventObj[@"description"] != nullInstance)
                              description = eventObj[@"description"];
                          eventDetail.eDescription = description;
                          
                          NSString *host = @"";
                          if (eventObj[@"host"] != nullInstance)
                              host = eventObj[@"host"];
                          eventDetail.host = host;
                          
                          NSString *privacy = @"";
                          if (eventObj[@"privacy"] != nullInstance)
                              privacy = eventObj[@"privacy"];
                          eventDetail.privacy = privacy;
                          
                          eventDetail.attendingCount = [eventObj[@"attending_count"] intValue];
                          eventDetail.unsureCount = [eventObj[@"unsure_count"] intValue];
                          eventDetail.unrepliedCount = [eventObj[@"not_replied_count"] intValue];
                      } else {
                          [self.delegate notifyEventDidNotExist];
                          eventExist = false;
                      }
                  }
                  if (eventExist) [self.delegate notifyEventDetailsQueryCompletedWithResult:eventDetail];
              }
          }
      }];
    
}


@end
