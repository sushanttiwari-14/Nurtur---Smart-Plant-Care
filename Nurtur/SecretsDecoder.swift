//
//  SecretsDecoder.swift
//  Nurtur
//
//  Created by sushant tiwari on 28/02/26.
//

import Foundation
enum Secrets{
    static var  WeatherApiKey:String{
        guard let key  = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String else {
            fatalError("WeatherApiKey not found in Info.plist")
        }
        return key
    }
}
