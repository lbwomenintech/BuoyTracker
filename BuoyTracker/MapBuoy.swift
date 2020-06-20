//
//  MapBuoy.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit
import MapKit

// NOTE: I would normally prefer not to fracture the model in a real project,
//       but writing an adaptor class is faster for a proof of concept

class MapBuoy: NSObject, MKAnnotation {
    
    init(buoy: Buoy) {
        self.buoy = buoy
        
        self.title = buoy.name
        self.subtitle = buoy.stationId
        
        if let latitude = buoy.latitude,
            let longitude = buoy.longitude {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
    }
    
    var buoy: Buoy
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
}

