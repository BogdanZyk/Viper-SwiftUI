//
//  ImageDataProvider.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import SwiftUI
import Combine

protocol ImageDataServiceProtocol {
  func getEndImages(for trip: Trip) -> AnyPublisher<[UIImage], Never>
}

private struct PixabayResponse: Codable {
  struct Image: Codable {
    let largeImageURL: String
    let user: String
  }

  let hits: [Image]
}


class PixabayImageDataService: ImageDataServiceProtocol {
  let apiKey = "29651159-7f92f05af368cfb8795bfd59e"

  private func searchURL(query: String) -> URL {
    var components = URLComponents(string: "https://pixabay.com/api")!
    components.queryItems = [
      URLQueryItem(name: "key", value: apiKey),
      URLQueryItem(name: "q", value: query),
      URLQueryItem(name: "image_type", value: "photo")
    ]
    return components.url!
  }

  private func imageForQuery(query: String) -> AnyPublisher<UIImage, Never> {
    URLSession.shared.dataTaskPublisher(for: searchURL(query: query))
    .map { $0.data }
    .decode(type: PixabayResponse.self, decoder: JSONDecoder())
      .tryMap { response -> URL in
        guard
          let urlString = response.hits.first?.largeImageURL,
          let url = URL(string: urlString)
          else {
            throw CustomErrors.noData
        }
          return url
    }.catch { _ in Empty<URL, URLError>() }
      .flatMap { URLSession.shared.dataTaskPublisher(for: $0) }
      .map { $0.data }
      .tryMap { imageData in
        guard let image = UIImage(data: imageData) else { throw CustomErrors.noData }
        return image
    }.catch { _ in Empty<UIImage, Never>()}
    .eraseToAnyPublisher()
  }

  func getEndImages(for trip: Trip) -> AnyPublisher<[UIImage], Never> {
    if trip.waypoints.count == 0 {
      return Empty<[UIImage], Never>()
        .eraseToAnyPublisher()
    }
    if trip.waypoints.count == 1 {
      return imageForQuery(query: trip.waypoints[0].name)
        .map { [$0] }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    let start = imageForQuery(query: trip.waypoints[0].name)
    let end = imageForQuery(query: trip.waypoints.last!.name)

    return Publishers.Merge(start, end)
      .collect()
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}
