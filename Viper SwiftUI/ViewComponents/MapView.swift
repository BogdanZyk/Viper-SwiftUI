//
//  MapView.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
  var pins: [MKAnnotation] = []
  var routes: [MKRoute]?
  var center: CLLocationCoordinate2D?

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {
    view.removeAnnotations(view.annotations)
    view.removeOverlays(view.overlays)
    if let center = center {
      view.setRegion(MKCoordinateRegion(center: center, latitudinalMeters: 2000, longitudinalMeters: 2000), animated: true)
      view.addAnnotation( {
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        return annotation
        }())
    }
    if pins.count > 0 {
      view.addAnnotations(pins)
      view.showAnnotations(pins, animated: false)
    }
    if let routes = routes {
      routes.forEach { route in
        view.addOverlay(route.polyline, level: .aboveRoads)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    init(_ parent: MapView) {
      self.parent = parent
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer(overlay: overlay)
      }

      let lineRenderer = MKPolylineRenderer(polyline: polyline)
      lineRenderer.strokeColor = .blue
      lineRenderer.lineWidth = 3

      return lineRenderer
    }
  }
}

fileprivate class CoordinateWrapper: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D

  init(_ coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
  }
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    let pins = DataModel.sample.trips[0].waypoints.map { waypoint -> MKPointAnnotation in
      let annotation = MKPointAnnotation()
      annotation.coordinate = waypoint.location
      return annotation
    }
    return Group {
      MapView(pins: pins, routes: nil, center: nil)
        .previewDisplayName("Pins")
      MapView(pins: [], routes: nil, center: CLLocationCoordinate2D.timesSquare)
        .previewDisplayName("Centered")
    }
  }
}
#endif
