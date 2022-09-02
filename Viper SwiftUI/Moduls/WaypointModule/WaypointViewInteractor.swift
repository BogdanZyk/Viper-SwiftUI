//
//  WaypointViewInteractor.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 02.09.2022.
//


import Foundation
import Combine
import CoreLocation

class WaypointViewInteractor {
  private let waypoint: Waypoint
  private let mapInfoProvider: MapDataServiceProtocol

  init(waypoint: Waypoint, mapInfoProvider: MapDataServiceProtocol) {
    self.waypoint = waypoint
    self.mapInfoProvider = mapInfoProvider
  }

  func getLocation(for address:String) -> AnyPublisher<CLPlacemark, Error> {
    mapInfoProvider.getLocation(for: address)
  }

  func apply(name: String, location: CLLocationCoordinate2D) {
    waypoint.name = name
    waypoint.location = location
  }
}
