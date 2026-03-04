//
//  PlantAPIResponse.swift
//  Nurtur
//
//  Created by sushant tiwari on 05/03/26.
//

import Foundation

struct PlantAPIResponse: Decodable {
    let suggestions: [PlantSuggestion]
}

struct PlantSuggestion: Decodable {
    let plant_name: String
    let probability: Double
}
