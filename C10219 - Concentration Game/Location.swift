//
//  Location.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 02/06/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import Foundation

class Location: Codable {
    
    var longitude : Double = 0
    var latitude : Double = 0

    init (){}
    
    init (latitude: Double, longitude: Double)
    {
        self.latitude = latitude
        self.longitude = longitude
    }
    public var toString: String {
        return "\(self.latitude),\(self.longitude)"
    }
}
