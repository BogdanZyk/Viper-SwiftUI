//
//  TripDetailInteractor.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 02.09.2022.
//

import Combine
import MapKit

class TripDetailInteractor {
    
    private let trip: Trip
    private let model: DataModel
    let mapInfoProvider: MapDataServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    var tripName: String {trip.name}
    var tripNamePublisher: Published<String>.Publisher { trip.$name }
    
    
    @Published var totalDistance: Measurement<UnitLength> = Measurement(value: 0, unit: .meters)
    @Published var waypoints: [Waypoint] = []
    @Published var directions: [MKRoute] = []
    
    init (trip: Trip, model: DataModel, mapInfoProvider: MapDataServiceProtocol) {
        self.trip = trip
        self.mapInfoProvider = mapInfoProvider
        self.model = model
        startMapSubscription()
    }
    
    
    private func startMapSubscription(){
        trip.$waypoints
          .assign(to: \.waypoints, on: self)
          .store(in: &cancellables)

        trip.$waypoints
            .flatMap { self.mapInfoProvider.totalDistance(for: $0) }
          .map { Measurement(value: $0, unit: UnitLength.meters) }
          .assign(to: \.totalDistance, on: self)
          .store(in: &cancellables)

        trip.$waypoints
          .setFailureType(to: Error.self)
          .flatMap { self.mapInfoProvider.directions(for: $0) }
          .catch { _ in Empty<[MKRoute], Never>() }
          .assign(to: \.directions, on: self)
          .store(in: &cancellables)
    }
    
    public func setTripName(_ name: String) {
        trip.name = name
    }
    
    public func save() {
        model.save()
    }
    
    
    func addWaypoint() {
       trip.addWaypoint()
    }

    func moveWaypoint(fromOffsets: IndexSet, toOffset: Int) {
     trip.waypoints.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func deleteWaypoint(atOffsets: IndexSet) {
      trip.waypoints.remove(atOffsets: atOffsets)
    }

    func updateWaypoints() {
      trip.waypoints = trip.waypoints
    }
}
