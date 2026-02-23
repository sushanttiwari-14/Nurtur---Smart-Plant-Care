//
//  AddPlantView.swift
//  Nurtur
//
//  Created by sushant tiwari on 19/02/26.
//

import SwiftUI

struct AddPlantView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var plantName: String = ""
    @State private var wateringFrequency: Int = 3
    
    var onSave: (String, Int) -> Void
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                HStack {
                    Text("Add Plant")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentGreen"))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plant Name")
                        .foregroundColor(Color("TextSecondary"))
                    
                    TextField("Enter plant name", text: $plantName)
                        .padding()
                        .background(Color("SurfaceBackground"))
                        .cornerRadius(12)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Watering Frequency (days)")
                        .foregroundColor(Color("TextSecondary"))
                    
                    Stepper("\(wateringFrequency) days", value: $wateringFrequency, in: 1...14)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                Spacer()
                
                Button {
                    onSave(plantName, wateringFrequency)
                    dismiss()
                } label: {
                    Text("Save Plant")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentGreen"))
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                .disabled(plantName.isEmpty)
            }
            .padding(24)
        }
    }
}

#Preview {
    AddPlantView { _, _ in }
        .preferredColorScheme(.dark)
}
