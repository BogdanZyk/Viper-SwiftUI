//
//  Trip.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import Foundation
import Combine

final class Trip {
  @Published var name: String = ""
  @Published var waypoints: [Waypoint] = []
  let id: UUID

  init() {
    id = UUID()
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    waypoints = try container.decode([Waypoint].self, forKey: .waypoints)
    id = try container.decode(UUID.self, forKey: .id)
  }

  func addWaypoint() {
    let waypoint = waypoints.last?.copy() ?? Waypoint()
    waypoint.name = "New Stop"
    waypoints.append(waypoint)
  }

}

extension Trip: Codable {
  enum CodingKeys: CodingKey {
    case name
    case waypoints
    case id
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(waypoints, forKey: .waypoints)
    try container.encode(id, forKey: .id)
  }
}

extension Trip: Equatable {
  static func == (lhs: Trip, rhs: Trip) -> Bool {
    lhs.id == rhs.id
  }
}

extension Trip: Identifiable {}

extension Trip: ObservableObject {}

