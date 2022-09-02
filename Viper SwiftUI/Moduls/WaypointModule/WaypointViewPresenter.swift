//
//  WaypointViewPresenter.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 02.09.2022.
//

import Combine
import SwiftUI
import CoreLocation

class WaypointViewPresenter: ObservableObject {
  @Published var query: String = ""

  @Published var info: String = "No results"
  @Published var name: String = "unknown"
  @Published var location: CLLocationCoordinate2D
  @Published var isValid: Bool = false

  private var cancellables = Set<AnyCancellable>()

  private let interactor: WaypointViewInteractor

  private func formatInfo(_ placemark: CLPlacemark) -> String {
    var info = placemark.name ?? "unknown"
    if let city = placemark.locality {
      info += ", \(city)"
    }
    if let state = placemark.administrativeArea {
      info += ", \(state)"
    }
    return info
  }

  init(waypoint: Waypoint, interactor: WaypointViewInteractor) {
    self.interactor = interactor
    location = waypoint.location
    query = waypoint.name

    $query
      .debounce(for: 0.5, scheduler: DispatchQueue.main)
      .sink(receiveValue: handleQuery)
      .store(in: &cancellables)
  }

  private func handleQuery(_ query: String) {
    let suggestion = interactor.getLocation(for: query)

    suggestion
      .map { self.formatInfo($0) }
      .catch { _ in Empty<String, Never>() }
      .assign(to: \.info, on: self)
      .store(in: &cancellables)

    suggestion
      .map { $0.name }
      .replaceNil(with: "unknown")
      .catch { _ in Empty<String, Never>() }
      .assign(to: \.name, on: self)
      .store(in: &cancellables)

    suggestion
      .map { $0.location }
      .replaceNil(with: CLLocation(latitude: 0, longitude: 0))
      .catch { _ in Empty<CLLocation, Never>() }
      .map { $0.coordinate }
      .assign(to: \.location, on: self)
      .store(in: &cancellables)

    suggestion
      .map { _ in true }
      .catch {_ in Just<Bool>(false) }
      .assign(to: \.isValid, on: self)
      .store(in: &cancellables)
  }

  func didTapUseThis() {
    interactor.apply(name: name, location: location)
  }
}
