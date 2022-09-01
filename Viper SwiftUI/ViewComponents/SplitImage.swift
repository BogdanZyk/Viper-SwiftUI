//
//  SplitImage.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import SwiftUI

struct SplitImage: View {
  var images: [UIImage]

  func defaultImageView() -> some View {
    Image("no_waypoints")
      .resizable()
      .aspectRatio(contentMode: .fill)
  }

  func image(for uiImage: UIImage) -> some View {
    return Image(uiImage: uiImage)
      .resizable()
      .aspectRatio(contentMode: .fill)
  }

  func oneImageView() -> some View {
    image(for: images[0])
  }

  func twoImagesView() -> some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        self.image(for: self.images[0])
          .frame(width: geometry.size.width)
          .clipShape(TopTriangle(offset: 4))
        self.image(for: self.images[1])
          .frame(width: geometry.size.width)
          .clipShape(BottomTriangle(offset: 4))
      }
    }
  }

  var body: some View {
    if images.count == 0 {
      return AnyView(defaultImageView())
    }
    if images.count == 1 {
      return AnyView(oneImageView())
    }
    return AnyView(twoImagesView())
  }
}

struct TopTriangle: Shape {
  var offset: CGFloat = 2
  func path(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - offset))
    path.closeSubpath()
    return path
  }
}

struct BottomTriangle: Shape {
  var offset: CGFloat = 2

  func path(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: rect.minX + offset, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + offset))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}


struct SplitImage_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SplitImage(images: [])
        .frame(height: 200)
      SplitImage(images: [UIImage(named: "waypoint.0")!])
        .frame(height: 100)
      SplitImage(images: [UIImage(named: "waypoint.1")!])
        .frame(height: 100)
      SplitImage(images: [UIImage(named: "waypoint.0")!, UIImage(named: "waypoint.1")!])
        .frame(height: 100)
    }
  }
}
