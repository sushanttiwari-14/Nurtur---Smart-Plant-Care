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
    
    // MARK: - Safe Care Score
    private var safeScore: Int {
        min(max(plant.careScore, 0), 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Top Section (Image + Care Score)
                HStack(alignment: .top, spacing: 20) {
                    
                    // Plant Image
                    if let path = plant.imagePath,
                       let image = ImageStorageManager.shared.loadImage(from: path) {
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 4)
                        
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 140, height: 140)
                            .overlay(
                                Image(systemName: "leaf")
                                    .font(.largeTitle)
                                    .foregroundColor(.green)
                            )
                    }
                    
                    Spacer()
                    
                    // Care Score Ring
                    ZStack {
                        
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 18)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(safeScore) / 100)
                            .stroke(
                                scoreColor,
                                style: StrokeStyle(lineWidth: 18, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.8), value: safeScore)
                        
                        VStack(spacing: 4) {
                            Text("Care")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(safeScore)%")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(width: 140, height: 140)
                }
                
                // MARK: - Plant Name
                Text(plant.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // MARK: - Next Watering
                section(title: "Next Watering", value: formattedNextDate)
                
                // MARK: - Last Watered
                section(title: "Last Watered", value: lastWateredText)
                
                // MARK: - Frequency
                section(
                    title: "Watering Frequency",
                    value: "Every \(plant.wateringFrequency) days"
                )
                
                // MARK: - Stats
                Text("Watered \(plant.wateringHistory.count) times")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Missed \(plant.missedCount) waterings")
                    .font(.subheadline)
                    .foregroundColor(plant.missedCount > 0 ? .red : .secondary)
                
                Spacer(minLength: 20)
                
                // MARK: - Water Button
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
            Button("OK", role: .cancel) {}
        } message: {
            Text("This plant has already been watered today.")
        }
    }
    
    // MARK: - Reusable Section Builder
    private func section(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
        }
    }
    
    // MARK: - Date Logic
    private var formattedNextDate: String {
        if plant.isOverdue { return "Overdue" }
        if plant.daysRemaining == 0 { return "Today" }
        if plant.daysRemaining == 1 { return "Tomorrow" }
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
    
    // MARK: - Care Score Color
    private var scoreColor: Color {
        switch safeScore {
        case 90...100: return .green
        case 70..<90: return .mint
        case 40..<70: return .orange
        default: return .red
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
