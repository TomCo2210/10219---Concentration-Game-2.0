//
//  MemoryIO.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 09/06/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import Foundation

class MemoryIO {
    var jsonConverter :JsonConverter = JsonConverter()
    
    // MARK: - Read From / Write To UserDefaults Standard Storage
    func writeToUserDefaults(highScores: [HighScore],level :String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(jsonConverter.fromListToJson(list: highScores), forKey: level)
    }
    
    func readFromUserDefaults(level:String) -> [HighScore]{
        let userDefaults = UserDefaults.standard
        if let highScores: [HighScore] = jsonConverter.fromJsonToList(json: userDefaults.string(forKey: level) ?? ""){
            return highScores
        }
        return [HighScore]()
    }
    // MARK: Clean User Defaults
    func clearUserDefaults(){
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
}
