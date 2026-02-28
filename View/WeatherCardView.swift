//
//  WeatherCardView.swift
//  Nurtur
//
//  Created by sushant tiwari on 25/02/26.
//

import SwiftUI

struct WeatherCardView: View {
    
    let temperature: Double
    let humidity: Int
    let condition: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // MARK: - Top Row (Icon + Temp + Humidity)
            HStack(spacing: 12) {
                
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(Color("AccentGreen"))
                
                Text("\(Int(temperature))°C")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Text("\(humidity)% Humidity")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
            }
            
            // MARK: - Condition Text
            Text(condition.capitalized)
                .font(.subheadline)
                .foregroundColor(Color("TextSecondary"))
            
            // MARK: - Smart Suggestion
            Text(smartMessage)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(suggestionColor)
        }
        .padding(16)
        .background(Color("SurfaceBackground"))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color("AccentGreen").opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 3)
    }
}
// MARK: - Smart Suggestion Logic
private extension WeatherCardView {
    
    var smartMessage: String {
        if humidity > 70 && temperature > 30 {
            return "Hot & humid. Soil may dry faster than usual."
        } else if humidity < 40 && temperature < 20 {
            return "Cool & dry. Reduce watering slightly."
        } else {
            return "Normal conditions for watering."
        }
    }
    
    var suggestionColor: Color {
        if humidity > 70 && temperature > 30 {
            return Color("AccentGreen")
        } else if humidity < 40 && temperature < 20 {
            return .blue
        } else {
            return Color("TextSecondary")
        }
    }
    
    var iconName: String {
        if temperature > 30 {
            return "sun.max.fill"
        } else if temperature < 15 {
            return "cloud.snow.fill"
        } else {
            return "cloud.sun.fill"
        }
    }
}


#Preview("Cool & Dry") {
    WeatherCardView(temperature: 18, humidity: 35, condition: "Clear")
}


