//
//  ScanViewModel.swift
//  Nurtur
//
//  Created by sushant tiwari on 03/03/26.
//
import Foundation
import UIKit
import Combine

@MainActor
final class ScanViewModel: ObservableObject {
    
    @Published var capturedImage: UIImage?
    @Published var detectedName: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: PlantRecognitionServiceProtocol
    
    init(service: PlantRecognitionServiceProtocol) {
        self.service = service
    }
    
    func recognizePlant() async {
        guard let image = capturedImage else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let name = try await service.identifyPlant(from: image)
            detectedName = name
        } catch {
            errorMessage = "Failed to identify plant. Please try again."
        }
        
        isLoading = false
    }
}
