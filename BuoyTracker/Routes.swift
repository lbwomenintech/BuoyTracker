//
//  Routes.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit
import MapKit

enum Routes {
    
    case buoyFeed(location: CLLocation, radius: Int)
    
    var path: String {
        get {
            switch self {
            case .buoyFeed(let location, let radius):
                // translate CLLocationCoordinates to NOAA query parameter coordinates
                let latitudeMagnitude = abs(location.coordinate.latitude)
                let latitudeDirection = (location.coordinate.latitude >= 0) ? "N" : "S"
                
                let longitudeMagnitude = abs(location.coordinate.longitude)
                let longitudeDirection = (location.coordinate.longitude >= 0) ? "E" : "W"
                
                return "https://www.ndbc.noaa.gov/rss/ndbc_obs_search.php?lat=\(latitudeMagnitude)\(latitudeDirection)&lon=\(longitudeMagnitude)\(longitudeDirection)&radius=\(radius)"
            }
        }
    }
    
}
