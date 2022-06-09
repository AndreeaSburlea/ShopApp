//
//  MapViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 07.06.2022.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // swiftlint:disable line_length
    // swiftlint:disable force_cast

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addressTitle: UILabel!
    @IBOutlet private var addressText: UILabel!

    private let storeLocations = "Strada Alexandru Vaida Voevod 53B, Cluj-Napoca 400436"

    override func viewDidLoad() {
        super.viewDidLoad()
        addressTitle.text = "You can find us here:"
        addressText.text = "Street Alexandru Vaida Voevod 53B, Cluj-Napoca 400436"
        tableView.delegate = self
        tableView.dataSource = self

        navigationItem.backButtonTitle = ""
//        tableView.contentInsetAdjustmentBehavior = .never
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LocationMapCell.self), for: indexPath) as! LocationMapCell
        cell.configure(location: storeLocations)
        cell.selectionStyle = .none
        return cell
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyMarker"

        if annotation.isKind(of: MKUserLocation.self) {
             return nil
         }

        // Reuse the annotation if possible
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }

        annotationView?.glyphText = " "
        annotationView?.markerTintColor = UIColor.orange

        return annotationView
    }
}
