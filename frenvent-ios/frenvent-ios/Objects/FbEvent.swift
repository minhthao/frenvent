//
//  FbEvent.swift
//  frenvent-ios
//
//  Created by minh thao nguyen on 6/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

import Foundation
import CoreData

class FbEvent: NSManagedObject {
    @NSManaged var eid: String
    @NSManaged var name: String
    @NSManaged var picture: String
    @NSManaged var startTime: Int
    @NSManaged var endTime: Int
    @NSManaged var privacy: String
    @NSManaged var location:String
    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var numInterested: Int
    @NSManaged var host: String
    @NSManaged var friendsInterested: String
    @NSManaged var rsvp: String
    
    var distance: Double = 0
    var attendingFriends = Attendee[]()
    
    /**
    * Compute
    */
    func getDistanceFrom(currentLongitue: Double, currentLatitude: Double) -> Double{
        //TODO write the function to compute distance. Standard is like this
        return -1;
    }
    
    
    //TODO 1: to get the display rsvp status on the list view // simple conversion of string
    
    
    /**
    * Get the display interested friends string of the event
    * @return name and how many friends are interested
    */
    func getDisplayInterestedFriends() -> String {
        if (attendingFriends.count < 1) {
            return String()
        } else if (attendingFriends.count == 1) {
            return "\(attendingFriends[0].name) is interested"
        } else if (attendingFriends.count == 2) {
            return "\(attendingFriends[0].name) and \(attendingFriends[1].name) are interested"
        } else {
            return "\(attendingFriends[0].name) and \(attendingFriends.count) other are interested"
        }
    }

    
    
    
    //TODO to write the conversion from the JSON and conversion to JSON in order to get/upload the public events
}