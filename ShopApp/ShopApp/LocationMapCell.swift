//
//  LocationMapCell.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 07.06.2022.
//

import UIKit
import MapKit

class LocationMapCell: UITableViewCell {

    @IBOutlet var mapView: MKMapView!

    func configure(location: String) {
        // Get location
        let geoCoder = CLGeocoder()
        print(location)
        geoCoder.geocodeAddressString(location, completionHandler: { placemarks, error in
            if let error = error {
                print(error.localizedDescription)

                return
            }
        if let placemarks = placemarks {
            // Get the first placemark
            let placemark = placemarks[0]

            // Add annotation
            let annotation = MKPointAnnotation()

            if let location = placemark.location {
                // Display the annotation
                annotation.coordinate = location.coordinate
                self.mapView.addAnnotation(annotation)
                
                // Set the zoom level
                let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
                self.mapView.setRegion(region, animated: false)
                }
            }
        })
    }
}
