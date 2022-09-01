//
//  MapDataService.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import Foundation
import Combine
import MapKit
import CoreLocation

protocol MapDataServiceProtocol {
  func getLocation(for address:String) -> AnyPublisher<CLPlacemark, Error>
  func directions(for waypoints:[Waypoint]) -> AnyPublisher<[MKRoute], Error>
  func totalDistance(for trip: [Waypoint]) -> AnyPublisher<Double, Never>
}

enum CustomErrors: String, Error {
  case unknown
  case noData
}

class RealMapDataProvider: MapDataServiceProtocol {
  let geocoder = CLGeocoder()

  func getLocation(for address:String) -> AnyPublisher<CLPlacemark, Error> {
    let subject = PassthroughSubject< CLPlacemark, Error>()

    geocoder.geocodeAddressString(address) { placemarks, error in
      if let placemark = placemarks?.first {
        subject.send(placemark)
        subject.send(completion: .finished)
      } else if let error = error {
        subject.send(completion: .failure(error))
      } else {
        subject.send(completion: .failure(CustomErrors.unknown))
      }
    }

    return subject
      .eraseToAnyPublisher()
  }

  func directions(for waypoints:[Waypoint]) -> AnyPublisher<[MKRoute], Error> {
    guard waypoints.count > 1 else {
      return Empty<[MKRoute], Error>().eraseToAnyPublisher()
    }

    var routePublishers: [AnyPublisher<[MKRoute], Error>] = []

    (0 ..< waypoints.count - 1).forEach { index in
      let start = waypoints[index]
      let end = waypoints[index + 1]

      let request = MKDirections.Request()
      request.transportType = .automobile
      request.source = start.mapItem
      request.destination = end.mapItem

      let directions = MKDirections(request: request)
      routePublishers.append(directions.calculate())
    }

    let allPublisher = Publishers.Sequence<[AnyPublisher<[MKRoute], Error>], Error>(sequence: routePublishers)
    return allPublisher.flatMap { $0 }
      .collect()
      .map { $0.compactMap { $0.first }} // get just the first route and make a list
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    }

  func totalDistance(for trip: [Waypoint]) -> AnyPublisher<Double, Never> {
    return directions(for: trip)
      .replaceError(with: [])
      .map { routes in
        routes.map { route in
          route.distance
        }.reduce(0, +)
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension MKDirections {
  func calculate() -> AnyPublisher<[MKRoute], Error> {
    let subject = PassthroughSubject<[MKRoute], Error>()
    calculate { response, error in
      if let routes = response?.routes {
        subject.send(routes)
        subject.send(completion: .finished)
      } else if let error = error {
        subject.send(completion: .failure(error))
      } else {
        subject.send(completion: .finished)
      }
    }
    return subject.eraseToAnyPublisher()
  }
}

extension CLLocationCoordinate2D {
  static var timesSquare: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: 40.757, longitude: -73.986)}
}
