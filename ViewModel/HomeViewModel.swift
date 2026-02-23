//
//  HomeViewModel.swift
//  Nurtur
//
//  Created by sushant tiwari on 19/02/26.
//

import Foundation
import Combine
import SwiftUI
import UserNotifications
class HomeViewModel: ObservableObject {
    private let storageKey = "saved_plants"
    init() {
//        loadPlants()
    }
    @Published var plants: [Plant] = [
        Plant(
            name: "Monstera",
            nextWateringDate: Date().addingTimeInterval(-2*86400),
            wateringFrequency: 2
        ),
        //to check care score manually to 50%
//        Plant(
//            name: "Monstera",
//            nextWateringDate: Date().addingTimeInterval(-2*86400),
//            wateringFrequency: 2,
//            wateringHistory: [Date()]
//        ),
        Plant(
            name: "Snake Plant",
            nextWateringDate: Date().addingTimeInterval(15*172800),
            wateringFrequency: 5
        ),
        Plant(
            name: "Aloevera",
            nextWateringDate: Date().addingTimeInterval(0),
            wateringFrequency: 2
        )
    ]
    var sortedPlants: [Plant] {
        plants.sorted { lhs, rhs in
            if lhs.isOverdue != rhs.isOverdue {
                return lhs.isOverdue
            }
            
            if lhs.daysRemaining == 0 && rhs.daysRemaining != 0 {
                return true
            }
            
            return lhs.nextWateringDate < rhs.nextWateringDate
        }
    }
    var overduePlants: [Plant] {
        plants
            .filter { $0.isOverdue }
            .sorted { $0.nextWateringDate < $1.nextWateringDate }
    }

    var todayPlants: [Plant] {
        plants
            .filter { $0.daysRemaining == 0 }
            .sorted { $0.nextWateringDate < $1.nextWateringDate }
    }

    var upcomingPlants: [Plant] {
        plants
            .filter { $0.daysRemaining > 0 }
            .sorted { $0.nextWateringDate < $1.nextWateringDate }
    }
    
    func addPlant(name: String, frequency: Int) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let nextDate = Calendar.current.date(
            byAdding: .day,
            value: frequency,
            to: Date()
        ) ?? Date()
        
        let newPlant = Plant(
            name: name,
            nextWateringDate: nextDate,
            wateringFrequency: frequency,
            wateringHistory: []
            
        )
        
        withAnimation(.easeInOut) {
            plants.append(newPlant)
            savePlants()
            scheduleNotification(for: newPlant)
        }
    }
    func markAsWatered(_ plant: Plant) -> Bool {

        let calendar = Calendar.current

        // Check if already watered today
        if let last = plant.wateringHistory.last,
           calendar.isDate(last, inSameDayAs: Date()) {
            return false
        }

        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else {
            return false
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        plants[index].wateringHistory.append(Date())

        let newDate = calendar.date(
            byAdding: .day,
            value: plants[index].wateringFrequency,
            to: Date()
        ) ?? Date()

        plants[index].nextWateringDate = newDate

        savePlants()
        scheduleNotification(for: plants[index])

        return true
    }
  
    func deletePlant(_ plant: Plant) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        cancelNotification(for: plant)
        plants.removeAll { $0.id == plant.id }
        savePlants()
        
    }
    

    private func savePlants() {
        if let encoded = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    private func loadPlants() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            plants = decoded
        }
    }
    private func scheduleNotification(for plant: Plant) {
        let content = UNMutableNotificationContent()
        content.title = "Water \(plant.name)"
        content.body = "It's time to water your plant 🌿"
        content.sound = .default

        let timeInterval = plant.nextWateringDate.timeIntervalSinceNow
//        let timeInterval: TimeInterval = 5

        guard timeInterval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: plant.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    private func cancelNotification(for plant: Plant) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [plant.id.uuidString]
            )
    }
    func updatePlant(_ plant: Plant, name: String, frequency: Int) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }

        plants[index].name = name
        plants[index].wateringFrequency = frequency
        
        // Recalculate next watering date
        if let lastWatered = plants[index].wateringHistory.last {
            let newNextDate = Calendar.current.date(
                byAdding: .day,
                value: frequency,
                to: lastWatered
            ) ?? Date()
            
            plants[index].nextWateringDate = newNextDate
        }

        savePlants()
        scheduleNotification(for: plants[index])
    } // if plant has water history and we edit its freq then next watering date should be last water date + freq not today+ freq 
    func filteredPlants(searchText: String) -> [Plant] {
        if searchText.isEmpty {
            return sortedPlants
        } else {
            return plants.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

