//
//  PlantRecognitionServiceProtocol.swift
//  Nurtur
//
//  Created by sushant tiwari on 03/03/26.
//

import Foundation
import UIKit

protocol PlantRecognitionServiceProtocol {
    func identifyPlant(from image: UIImage) async throws -> String
}
