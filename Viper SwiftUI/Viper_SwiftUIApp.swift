//
//  Viper_SwiftUIApp.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import SwiftUI

@main
struct Viper_SwiftUIApp: App {
    @StateObject var model = DataModel()
    init(){
        model.load()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
