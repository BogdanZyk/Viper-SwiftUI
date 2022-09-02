//
//  TripDetailPresenter.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 02.09.2022.
//

import SwiftUI
import Combine

class TripDetailPresenter: ObservableObject {
    
    private let interactor: TripDetailInteractor
    private let router: TripDetailRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var tripName: String = "No name"
    @Published var distanceLabel: String = "Calculating..."
    @Published var waypoints: [Waypoint] = []
    
    let setTripName: Binding<String>
    
    init(interactor: TripDetailInteractor) {
        self.interactor = interactor
        self.router = TripDetailRouter(mapProvider: interactor.mapInfoProvider)
        
        setTripName = Binding<String>(
          get: { interactor.tripName },
          set: { interactor.setTripName($0) }
        )
        
        startTripNameSubscription()
        
        startsMapSubscription()
    }
    
    
    func makeMapView() -> some View {
        TripMapView(presenter: TripMapViewPresenter(interactor: interactor))
    }
    
    public func save() {
        interactor.save()
    }
    
    private func startTripNameSubscription(){
        interactor.tripNamePublisher
            .assign(to: \.tripName, on: self)
            .store(in: &cancellables)
    }
    
    
    private func startsMapSubscription(){
        interactor.$totalDistance
            .map { "Total Distance: " + MeasurementFormatter().string(from: $0) }
            .replaceNil(with: "Calculating...")
            .assign(to: \.distanceLabel, on: self)
            .store(in: &cancellables)
        
        interactor.$waypoints
            .assign(to: \.waypoints, on: self)
            .store(in: &cancellables)
    }
    
    func addWaypoint() {
      interactor.addWaypoint()
    }

    func didMoveWaypoint(fromOffsets: IndexSet, toOffset: Int) {
      interactor.moveWaypoint(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func didDeleteWaypoint(_ atOffsets: IndexSet) {
      interactor.deleteWaypoint(atOffsets: atOffsets)
    }

    func cell(for waypoint: Waypoint) -> some View {
      let destination = router.makeWaypointView(for: waypoint)
        .onDisappear(perform: interactor.updateWaypoints)
      return NavigationLink(destination: destination) {
        Text(waypoint.name)
      }
    }
}
