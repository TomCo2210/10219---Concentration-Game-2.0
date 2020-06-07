//
//  HighScore.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 02/06/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import Foundation

class HighScore : Codable{
    
    var timeElapsed:Int = 0
    var playerName:String = ""
    var gameLocation:Location = Location()
    var dateOfGame:String = ""
    
    init() {
        
    }
    
    init (timeElapsed:Int, playerName:String, gameLocation:Location){
        self.timeElapsed = timeElapsed
        self.playerName = playerName
        self.gameLocation = gameLocation
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.locale = .current
        self.dateOfGame = formatter.string(from: now)
    }
}
