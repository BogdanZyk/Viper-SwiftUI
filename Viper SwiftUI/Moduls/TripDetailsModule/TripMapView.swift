//
//  TripMapView.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 02.09.2022.
//

import SwiftUI

struct TripMapView: View {
    @ObservedObject var presenter: TripMapViewPresenter
    var body: some View {
        MapView(pins: presenter.pins, routes: presenter.routes)
    }
}

struct TripMapView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DataModel.sample
        let trip = model.trips[1]
        let interactor = TripDetailInteractor(trip: trip, model: model, mapInfoProvider: RealMapDataProvider())
        let presenter = TripMapViewPresenter(interactor: interactor)
        return VStack {
            TripMapView(presenter: presenter)
        }
    }
}
