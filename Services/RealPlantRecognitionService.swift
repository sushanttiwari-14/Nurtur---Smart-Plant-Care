//
//  RealPlantRecognitionService.swift
//  Nurtur
//
//  Created by sushant tiwari on 05/03/26.
//

import Foundation
import UIKit

final class RealPlantRecognitionService: PlantRecognitionServiceProtocol {
    
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PLANT_API_KEY") as? String else {
            fatalError("PLANT_API_KEY not found")
        }
        return key
    }
    func identifyPlant(from image: UIImage) async throws -> String {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.badURL)
        }
        
        let base64Image = imageData.base64EncodedString()
        
        guard let url = URL(string: "https://api.plant.id/v2/identify") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "Api-Key")
        
        let body: [String: Any] = [
            "images": [base64Image],
            "organs": ["leaf"]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(PlantAPIResponse.self, from: data)
        
        guard let bestSuggestion = decoded.suggestions.max(by: {
            $0.probability < $1.probability
        }) else {
            return "Unknown Plant"
        }

        if bestSuggestion.probability < 0.5 {
            return "Plant not recognized clearly"
        }

        return bestSuggestion.plant_name
    }
}
