//
//  ScanResultView.swift
//  Nurtur
//
//  Created by sushant tiwari on 02/03/26.
//

import SwiftUI

struct ScanResultView: View {
    
    let image: UIImage
    @State var plantName: String
    @State var frequency: Int = 3
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    var onComplete: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plant Name")
                        .font(.headline)
                    
                    TextField("Enter plant name", text: $plantName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Watering Frequency (days)")
                        .font(.headline)
                    
                    Stepper("\(frequency) days",
                            value: $frequency,
                            in: 1...14)
                }
                
                Button {
                    savePlant()
                } label: {
                    Text("Confirm & Add Plant")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentGreen"))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
        .navigationTitle("Confirm Plant")
    }
    
    private func savePlant() {
        guard let path = ImageStorageManager.shared.saveImage(image) else {
            return
        }

        homeViewModel.addPlant(
            name: plantName,
            frequency: frequency,
            imagePath: path
        )

        dismiss()   // only dismiss ScanResultView
        onComplete()
    }
}
#Preview {
    ScanResultView(
        image: UIImage(systemName: "leaf")!,
        plantName: "Monstera", onComplete: {}
    )
    .environmentObject(HomeViewModel())
}
