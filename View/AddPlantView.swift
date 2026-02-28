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
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    var onSave: (String, Int,String) -> Void
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            Button {
                showImagePicker = true
            } label: {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 150)
                        .overlay(
                            Text("Tap to add plant image")
                                .foregroundColor(.gray)
                        )
                }
            }
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
                    // user selected image
                       guard let image = selectedImage else {
                           return
                       }
                       
                       //  Save image to disk and get file path
                       guard let path = ImageStorageManager.shared.saveImage(image) else {
                           return
                       }
                    onSave(plantName, wateringFrequency, path)
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                selectedImage = image
            }
        }
    }
}

#Preview {
    AddPlantView { _, _, _ in }
        .preferredColorScheme(.dark)
}
