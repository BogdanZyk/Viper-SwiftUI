//
//  TripListView.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import SwiftUI

struct TripListView: View {
    @ObservedObject var presenter: TripListPresenter
    var body: some View {
        List {
          ForEach (presenter.trips, id: \.id) { item in
            TripListCell(trip: item)
              .frame(height: 240)
          }
          .onDelete(perform: presenter.deleteTrip)
        }
        .listStyle(.plain)
        .navigationBarTitle("Roadtrips", displayMode: .inline)
        .navigationBarItems(trailing: presenter.makeAddNewButton())
    }
}

struct TripListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let model = DataModel.sample
        let interactor = TripListInteractor(model: model)
        let presenter = TripListPresenter(interactor: interactor)
        NavigationView{
            TripListView(presenter: presenter)
        }
    }
}
