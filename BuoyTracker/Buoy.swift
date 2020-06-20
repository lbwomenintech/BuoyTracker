//
//  Buoy.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit
import MapKit

class Buoy: NSObject {
    var name: String?
    var stationId: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    var descriptionString: String?
    
    var isFavorite: Bool = false
}
