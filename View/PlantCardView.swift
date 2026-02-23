//
//  PlantCardView.swift
//  Nurtur
//
//  Created by sushant tiwari on 18/02/26.
//

import SwiftUI

struct PlantCardView: View {
    
    var plant: Plant
    var onWater: () -> Void
    
    var body: some View {
       
            HStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("AccentGreen").opacity(0.2))
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(plant.name)
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundColor(statusColor)
                  
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                Image(systemName: "drop.fill")
                    .foregroundColor(Color("AccentGreen"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color("SurfaceBackground"))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, style: StrokeStyle(lineWidth: 1.5)
            )
            )
        
        .buttonStyle(.plain)
    }
    
    // MARK: - Status Logic
    
    private var statusText: String {
        if plant.isOverdue {
            return "Overdue"
        } else if plant.daysRemaining == 0 {
            return "Water today"
        } else {
            return "In \(plant.daysRemaining) days"
        }
    }
    
    private var statusColor: Color {
        if plant.isOverdue {
            return .red
        } else if plant.daysRemaining == 0 {
            return Color("AccentLight")
        } else {
            return Color("TextSecondary")
        }
    }
    private var borderColor: Color {
        if plant.isOverdue {
            return .red
        } else if plant.daysRemaining == 0 {
            return Color("AccentLight")
        } else {
            return .clear
        }
    }
}

#Preview {
    ZStack {
        Color("AppBackground")
            .ignoresSafeArea()
        
        PlantCardView(
            plant: Plant(
                name: "Monstera",
                nextWateringDate: Date().addingTimeInterval(86400),
                wateringFrequency: 3
            )
        ) { }
        .padding()
    }
    .preferredColorScheme(.dark)
}
