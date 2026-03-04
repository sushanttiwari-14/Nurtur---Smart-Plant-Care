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
        
        let url = URL(string: "https://api.plant.id/v2/identify")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "Api-Key")
        
        let body: [String: Any] = [
            "images": [base64Image],
            "organs": ["leaf"]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(PlantAPIResponse.self, from: data)
        
        return decoded.suggestions.first?.plant_name ?? "Unknown Plant"
    }
}
