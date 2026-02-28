//
//  PlantDetailView.swift
//  Nurtur
//
//  Created by sushant tiwari on 21/02/26.
//

import SwiftUI

struct PlantDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var plant: Plant
    @State private var showWaterWarning = false
    @State private var showEditSheet = false
    var onWater: () -> Bool
    var onEdit: (String, Int) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Plant Name
                Text(plant.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                //Progress ring which show care score of plant
                VStack(spacing: 16) {

                    ZStack {

                        // Background track circle
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 20)

                        // Progress circle
                        Circle()
                            .trim(from: 0, to: CGFloat(plant.careScore) / 100)
                            .stroke(
                                scoreColor,
                                style: StrokeStyle(
                                    lineWidth: 20,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: plant.careScore)

                        // Percentage text
                        Text("\(plant.careScore)%")
                            .font(.system(size: 44, weight: .bold))
                    }
                    .frame(width: 200, height: 200)

                    Text(careLabel)
                        .font(.headline)
                        .foregroundColor(scoreColor)

                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                
                // Next Watering
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Watering")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(formattedNextDate)
                        .font(.title3)
                }
                
                // Last Watered
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Watered")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(lastWateredText)
                        .font(.title3)
                }
                
                // Frequency
                VStack(alignment: .leading, spacing: 4) {
                    Text("Watering Frequency")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Every \(plant.wateringFrequency) days")
                        .font(.title3)
                }
//                Text("Care Score\(plant.careScore)")
                
                // Total Times
                Text("Watered \(plant.wateringHistory.count) times")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Missed \(plant.missedCount) waterings")
                    .font(.subheadline)
                    .foregroundColor(plant.missedCount > 0 ? .red : .secondary)
                
                Spacer(minLength: 16)
                
                Button {
                    let success = onWater()
                    if success {
                        dismiss()
                    } else {
                        showWaterWarning = true
                    }
                } label: {
                    Text("Mark as Watered")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentGreen"))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
        .navigationTitle("Plant Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditPlantView(
                name: plant.name,
                frequency: plant.wateringFrequency
            ) { newName, newFrequency in
                onEdit(newName, newFrequency)
            }
        }
        .alert("Already Watered", isPresented: $showWaterWarning) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This plant has already been watered today.")
        }
    }
    
    private var formattedNextDate: String {
        _ = Calendar.current
        
        if plant.isOverdue {
            return "Overdue"
        }
        
        if plant.daysRemaining == 0 {
            return "Today"
        }
        
        if plant.daysRemaining == 1 {
            return "Tomorrow"
        }
        
        return "In \(plant.daysRemaining) days"
    }
    
    private var lastWateredText: String {
        guard let last = plant.wateringHistory.last else {
            return "Not watered yet"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(last) {
            return "Today at \(formatTime(last))"
        }
        
        if calendar.isDateInYesterday(last) {
            return "Yesterday at \(formatTime(last))"
        }
        
        return formatFullDate(last)
    }
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    private var scoreColor: Color {
        switch plant.careScore {
        case 90...100:
            return .green
        case 70..<90:
            return .mint
        case 40..<70:
            return .orange
        default:
            return .red
        }
    }

    private var careLabel: String {
        switch plant.careScore {
        case 90...100:
            return "Perfect Care 🌿"
        case 70..<90:
            return "Excellent Care"
        case 40..<70:
            return "Improving"
        default:
            return "Needs Attention"
        }
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(
            plant: .constant(Plant(
                id: UUID(),
                name: "Monstera",
                nextWateringDate: Date().addingTimeInterval(86400),
                wateringFrequency: 3,
                imagePath: "",
                wateringHistory: [Date()]
            )),
            onWater: {
                print("Water tapped")
                return true
            },
            onEdit: { _, _ in
                print("Edit tapped")
            }
        )
    }
}
