//
//  MapViewController.swift
//  WhyCookIn
//
//  Created by Joowon Jang on 12/22/24.
//


import UIKit
import NMapsMap

class MapViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restaurants Map"  // Set a title if needed.
        view.backgroundColor = .systemBackground

        // 1) Create the Naver map view:
        let mapView = NMFMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // 2) Optionally add a scale view (the distance scale):
        let scaleView = NMFScaleView()
        scaleView.mapView = mapView
        scaleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scaleView)

        // 3) Pin the scale view at any position you’d like. For example, bottom-left:
        NSLayoutConstraint.activate([
            scaleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            scaleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            scaleView.widthAnchor.constraint(equalToConstant: 100),
            scaleView.heightAnchor.constraint(equalToConstant: 30)
        ])

        // 4) Optionally configure the map camera:
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.5670135, lng: 126.9783740), zoomTo: 14)
        mapView.moveCamera(cameraUpdate)

        // 5) If you prefer to show user location (requires user permission flow):
        // mapView.positionMode = .direction // or .compass / .normal
    }
}
