//
//  JsonConverter.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 09/06/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import Foundation

class JsonConverter {
    
    //MARK: - JSON Convertion
    func fromListToJson(list: [HighScore]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(list)
        let jsonString: String = String(data: data, encoding: .utf8)!
        return jsonString
    }
    
    func fromJsonToList(json: String) -> [HighScore]? {
        let decoder = JSONDecoder()
        if json == "" {
            return [HighScore]()
        }else{
            let data: [HighScore]
            let convertedData: Data = json.data(using: .utf8)!
            data = try! decoder.decode([HighScore].self,from: convertedData)
            return data
        }
    }
}
