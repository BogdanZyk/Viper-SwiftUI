//
//  TripDetailRouter.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 02.09.2022.
//

import SwiftUI

class TripDetailRouter {
  private let mapProvider: MapDataServiceProtocol

  init(mapProvider: MapDataServiceProtocol) {
    self.mapProvider = mapProvider
  }

  func makeWaypointView(for waypoint: Waypoint) -> some View {
    let presenter = WaypointViewPresenter(
      waypoint: waypoint,
      interactor: WaypointViewInteractor(
        waypoint: waypoint,
        mapInfoProvider: mapProvider))
    return WaypointView(presenter: presenter)
  }
    
    
}
