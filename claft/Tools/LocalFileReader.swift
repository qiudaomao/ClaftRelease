//
//  LocalFileReader.swift
//  claft
//
//  Created by zfu on 2021/12/8.
//

import Foundation

//var previewConfigData: ConfigData = getLocalData("config")
#if DEBUG
var previewConnectionData: ConnectionData = getLocalData("connection")

func getLocalData<T: Decodable>(_ fileName: String) -> T {
    let data: Data
    guard let file = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        fatalError("Cound't found file \(fileName)")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Cound't load data from \(fileName) error: \(error)")
    }
    
    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse JSON file \(fileName) error: \(error)")
    }
}
#endif
