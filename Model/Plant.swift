//
//  Plant.swift
//  Nurtur
//
//  Created by sushant tiwari on 18/02/26.
//

import Foundation
struct Plant : Identifiable , Codable
{
    var id = UUID()
    var name : String
    var nextWateringDate : Date
    var wateringFrequency: Int
    var imagePath: String
    var wateringHistory: [Date] = []
    var isOverdue: Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: nextWateringDate) <
               calendar.startOfDay(for: Date())
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: Date())
        let nextDate = calendar.startOfDay(for: nextWateringDate)
        
        let components = calendar.dateComponents([.day], from: today, to: nextDate)
        
        return components.day ?? 0
    }
    var missedCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let nextDate = calendar.startOfDay(for: nextWateringDate)

        // If not overdue → no missed watering
        guard today > nextDate else { return 0 }

        // How many days late?
        let daysLate = calendar.dateComponents([.day], from: nextDate, to: today).day ?? 0

        // How many watering cycles were missed?
        return max(1, daysLate / wateringFrequency)
    }
    var careScore: Int {
        let total = wateringHistory.count + missedCount
        guard total > 0 else { return 100 }

        let ratio = Double(wateringHistory.count) / Double(total)
        return Int(ratio * 100)
    }
}
