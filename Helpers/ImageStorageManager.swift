//
//  ImageStorageManager.swift
//  Nurtur
//
//  Created by sushant tiwari on 28/02/26.
//

import Foundation
import UIKit

final class ImageStorageManager {
    
    static let shared = ImageStorageManager()
    
    private init() {}
    
    private var imagesDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent("plant_images")
        
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        
        return folder
    }
    
    func saveImage(_ image: UIImage) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Failed to save image:", error)
            return nil
        }
    }
    
    func loadImage(from path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }
    
    func deleteImage(at path: String?) {
        guard let path = path else { return }

        let url: URL
        if path.hasPrefix("/") || path.hasPrefix("file://") {
            // Treat as absolute path
            url = URL(fileURLWithPath: path)
        } else {
            // Treat as filename relative to our images directory
            url = imagesDirectory.appendingPathComponent(path)
        }

        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Failed to delete image:", error)
        }
    }
}
