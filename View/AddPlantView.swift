import SwiftUI

struct AddPlantView: View {
    
    @State private var showScan = false
    @State private var showImagePicker = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State private var plantName: String = ""
    @State private var wateringFrequency: Int = 3
    @State private var selectedImage: UIImage?
        
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            ScrollView {
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
                    
                    Button {
                        showScan = true
                    } label: {
                        HStack {
                            Image(systemName: "camera")
                            Text("Scan with Camera")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color("SurfaceBackground"))
                        .cornerRadius(12)
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
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Watering Frequency (days)")
                            .foregroundColor(Color("TextSecondary"))
                        
                        Stepper("\(wateringFrequency) days",
                                value: $wateringFrequency,
                                in: 1...14)
                            .foregroundColor(Color("TextPrimary"))
                    }
                    
                    Button {
                        guard let image = selectedImage else { return }
                        guard let path = ImageStorageManager.shared.saveImage(image) else { return }
                        
                        homeViewModel.addPlant(
                            name: plantName,
                            frequency: wateringFrequency,
                            imagePath: path
                        )
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
                    .padding(.top, 10)
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                selectedImage = image
            }
        }
        .sheet(isPresented: $showScan) {
            NavigationStack {
                ScanView(
                    service: MockPlantRecognitionService()
                ) {
                    dismiss()
                }
                .environmentObject(homeViewModel)
                    .environmentObject(homeViewModel)
            }
        }
    }
}

#Preview {
    AddPlantView()
        .environmentObject(HomeViewModel())
        .preferredColorScheme(.dark)
}
