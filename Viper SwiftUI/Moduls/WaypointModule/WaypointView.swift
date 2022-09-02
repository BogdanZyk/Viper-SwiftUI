//
//  WaypointView.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 02.09.2022.
//

import SwiftUI
import Combine
import CoreLocation
import MapKit

struct WaypointView: View {
  @EnvironmentObject var model: DataModel
  @Environment(\.dismiss) var dismiss

  @ObservedObject var presenter: WaypointViewPresenter

  init(presenter: WaypointViewPresenter) {
    self.presenter = presenter
  }

  func applySuggestion() {
    presenter.didTapUseThis()
      dismiss()
  }

  var body: some View {
    return
      VStack{
        VStack {
          TextField("Type an Address", text: $presenter.query)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          HStack {
            Text(presenter.info)
            Spacer()
            Button(action: applySuggestion) {
              Text("Use this")
            }.disabled(!presenter.isValid)
          }

        }.padding([.horizontal])
        MapView(center: presenter.location)
      }.navigationBarTitle(Text(""), displayMode: .inline)
  }
}

#if DEBUG
struct WaypointView_Previews: PreviewProvider {
  static var previews: some View {
    let model = DataModel.sample
    let waypoint = model.trips[0].waypoints[0]
    let provider = RealMapDataProvider()

    return
      Group {
        NavigationView {
          WaypointView(presenter: WaypointViewPresenter(waypoint: waypoint, interactor: WaypointViewInteractor(waypoint: waypoint, mapInfoProvider: provider)))
            .environmentObject(model)
        }.previewDisplayName("Detail")
        NavigationView {
          WaypointView(presenter: WaypointViewPresenter(waypoint: Waypoint(), interactor: WaypointViewInteractor(waypoint:  Waypoint(), mapInfoProvider: provider)))
            .environmentObject(model)
            .previewDisplayName("New")
        }
    }
  }
}
#endif
