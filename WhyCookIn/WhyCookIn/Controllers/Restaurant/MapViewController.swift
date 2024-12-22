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

        // (A) Create the map view (full-screen):
        let mapView = NMFMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        // (B) Optionally configure some UI:
        mapView.mapType = .basic
        mapView.uiSettings.isScaleBarEnabled = true

        // (C) Set initial camera location:
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.57, lng: 126.9784), zoomTo: 15)
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)

        // (D) Put a marker on the map:
        let marker = NMFMarker(position: NMGLatLng(lat: 37.57, lng: 126.9784))
        marker.captionText = "Gwanghwamun"
        marker.mapView = mapView
    }
}
