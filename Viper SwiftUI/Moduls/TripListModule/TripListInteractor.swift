//
//  TripListInteractor.swift
//  Viper SwiftUI
//
//  Created by Богдан Зыков on 01.09.2022.
//

import Foundation
import Combine


class TripListInteractor{
    
    let model: DataModel
    
    init (model: DataModel) {
        self.model = model
    }
    
    public func addNewTrip() {
        model.pushNewTrip()
    }
    
    public func deleteTrip(_ index: IndexSet) {
        model.trips.remove(atOffsets: index)
    }
    
}
