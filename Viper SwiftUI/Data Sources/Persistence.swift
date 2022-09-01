//
//  Persistence.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import Foundation
import Combine

fileprivate struct Envelope: Codable {
  let trips: [Trip]
}


// This class can be refactored to save/load over a network instead of a local file


class Persistence {
  var localFile: URL {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("trips.json")
    print("In case you need to delete the database: \(fileURL)")
    return fileURL
  }
  
  var defaultFile: URL {
    return Bundle.main.url(forResource: "default", withExtension: "json")!
  }

  private func clear() {
    try? FileManager.default.removeItem(at: localFile)
  }

  func load() -> AnyPublisher<[Trip], Never>  {
    if FileManager.default.fileExists(atPath: localFile.standardizedFileURL.path) {
      return Future<[Trip], Never> { promise in
        self.load(self.localFile) { trips in
          DispatchQueue.main.async {
            promise(.success(trips))
          }
        }
      }.eraseToAnyPublisher()
    } else {
      return loadDefault()
    }
  }

  func save(trips: [Trip]) {
    let envelope = Envelope(trips: trips)
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(envelope)
    try! data.write(to: localFile)
  }

  private func loadSynchronously(_ file: URL) -> [Trip] {
    do {
      let data = try Data(contentsOf: file)
      let envelope = try JSONDecoder().decode(Envelope.self, from: data)
      return envelope.trips
    } catch {
      clear()
      return loadSynchronously(defaultFile)
    }
  }

  private func load(_ file: URL, completion: @escaping ([Trip]) -> Void) {
    DispatchQueue.global(qos: .background).async {
      let trips = self.loadSynchronously(file)
      completion(trips)
    }
  }

  func loadDefault(synchronous: Bool = false) -> AnyPublisher<[Trip], Never> {
    if synchronous {
      return Just<[Trip]>(loadSynchronously(defaultFile)).eraseToAnyPublisher()
    }
    return Future<[Trip], Never> { promise in
      self.load(self.defaultFile) { trips in
        DispatchQueue.main.async {
          promise(.success(trips))
        }
      }
    }.eraseToAnyPublisher()
  }
}

