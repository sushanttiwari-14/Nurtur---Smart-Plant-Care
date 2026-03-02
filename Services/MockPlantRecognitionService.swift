//
//  MockPlantRecognitionService.swift
//  Nurtur
//
//  Created by sushant tiwari on 02/03/26.
//

import Foundation
import UIKit

final class MockPlantRecognitionService: PlantRecognitionServiceProtocol {

        func identifyPlant(from image : UIImage) async throws -> String{
            try await Task.sleep(nanoseconds: 2_000_000_000)
            let plant = [
                "Monstera",
                "Snake Plant",
                "Aloe Vera",
                "Peace Lily",
                "Fiddle Leaf Fig"
            ]
            return plant.randomElement()?.capitalized ?? "Unknown Plant"

    }
}
