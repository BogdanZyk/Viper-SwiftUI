//
//  DataModel.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import Combine

import Combine

final class DataModel {
  private let persistence: Persistence = Persistence()

  @Published var trips: [Trip] = []

  private var cancellables = Set<AnyCancellable>()

    init(){
        load()
    }
    
  func load() {
    persistence.load()
      .assign(to: \.trips, on: self)
      .store(in: &cancellables)
  }

  func save() {
    persistence.save(trips: trips)
  }

  func loadDefault(synchronous: Bool = false) {
    persistence.loadDefault(synchronous: synchronous)
      .assign(to: \.trips, on: self)
      .store(in: &cancellables)
  }

  func pushNewTrip() {
    let new = Trip()
    new.name = "New Trip"
    trips.insert(new, at: 0)
  }

  func removeTrip(trip: Trip) {
    trips.removeAll { $0.id == trip.id }
  }
}

extension DataModel: ObservableObject {}

/// Extension for SwiftUI previews
#if DEBUG
extension DataModel {
  static var sample: DataModel {
    let model = DataModel()
    model.loadDefault(synchronous: true)
    return model
  }
}
#endif

