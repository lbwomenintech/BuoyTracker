//
//  BuoyMapViewController.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit
import MapKit

class BuoyMapViewController: UIViewController, BuoyRequester, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var buoyList: [Buoy] = [] {
        didSet {
            reloadData()
        }
    }
    
    var mapBuoyList: [MapBuoy] = []
    
    let radius: CLLocationDistance = 250000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        centerMapOnLocation(location: hardCodedLocation)
        self.title = "Map"
        
        if BuoyService.shared.buoyList.count == 0 {
            fetchBuoyData(fromLocation: hardCodedLocation)
        } else {
            buoyList = BuoyService.shared.buoyList
        }
    }
    
    func reloadData() {
        for buoy in buoyList {
            let buoyAnnotation = MapBuoy(buoy: buoy)
            mapBuoyList.append(buoyAnnotation)
            mapView.addAnnotation(buoyAnnotation)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion =
            MKCoordinateRegion(center: location.coordinate,
                               latitudinalMeters: radius,
                               longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapBuoy else { return nil }
        let identifier = "marker"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let mapBuoy = view.annotation as? MapBuoy {
            let detailViewController = BuoyDetailViewController.instantiate(withBuoy: mapBuoy.buoy)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }

    }
    
}
