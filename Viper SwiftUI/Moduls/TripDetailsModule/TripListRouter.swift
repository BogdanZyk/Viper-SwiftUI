//
//  TripListRouter.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 02.09.2022.
//

import SwiftUI

class TripListRouter {
  func makeDetailView(for trip: Trip, model: DataModel) -> some View {
    let presenter = TripDetailPresenter(interactor:
      TripDetailInteractor(
        trip: trip,
        model: model,
        mapInfoProvider: RealMapDataProvider()))
    return TripDetailView(presenter: presenter)
  }
}
