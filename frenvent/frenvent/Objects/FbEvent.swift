//
//  FbEvent.swift
//  frenvent
//
//  Created by Minh Thao Nguyen on 6/10/14.
//  Copyright (c) 2014 frenvent. All rights reserved.
//

import Foundation

class FbEvent {
    var eid = String()
    var name = String()
    var picture = String()
    var startTime: Int = 0
    var endTime: Int = 0
    var privacy = String()
    var location = String()
    var longitude: Double = 0
    var latitude: Double = 0
    var totalInterested: Int = 0
    var host = String()
    
    var distance: Double = 0    //this variable did not subject to the conversion below
    
    //TODO to write the conversion from the JSON and conversion to JSON in order to get/upload the public events
}