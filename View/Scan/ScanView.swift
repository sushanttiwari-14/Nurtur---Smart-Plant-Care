//
//  ScanView.swift
//  Nurtur
//
//  Created by sushant tiwari on 01/03/26.
//

import SwiftUI

struct ScanView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 24) {
            
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(16)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            Button("Open Camera") {
                showCamera = true
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("AccentGreen"))
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Scan Plant")
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                self.capturedImage = image
            }
        }
    }
}

#Preview {
    ScanView()
}
