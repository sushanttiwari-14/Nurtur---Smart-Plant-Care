import SwiftUI

struct ScanView: View {
    
    @State private var showError = false
    @State private var errorMessage = ""
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var isLoading = false
    @State private var detectedName: String?
    @State private var navigateToResult = false

    private let recognitionService: PlantRecognitionServiceProtocol
    var onPlantSaved: (() -> Void)?
    init(
        service: PlantRecognitionServiceProtocol,
        onPlantSaved: (() -> Void)? = nil
    ) {
        self.recognitionService = service
        self.onPlantSaved = onPlantSaved
    }
    var body: some View {
        VStack(spacing: 24) {
            
            if let image = capturedImage {
                
                VStack(spacing: 12) {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(16)
                    
                    Button("Retake Photo") {
                        capturedImage = nil
                        detectedName = nil
                        showCamera = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
                
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
            
            if isLoading {
                ProgressView("Identifying plant...")
                    .padding()
            }
            
            Button("Open Camera") {
                showCamera = true
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("AccentGreen"))
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationTitle("Scan Plant")
        .navigationDestination(isPresented: $navigateToResult) {
            if let image = capturedImage,
               let name = detectedName {
                
                ScanResultView(
                    image: image,
                    plantName: name
                ){
                    dismiss()
                    onPlantSaved?()
                }
                .environmentObject(homeViewModel)
                .onDisappear {
                    // When confirmation screen disappears,
                    // close ScanView and AddPlantView
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                self.capturedImage = image
                recognizePlant(image)
            }
        }
    }
    
    private func recognizePlant(_ image: UIImage) {
        
        isLoading = true
        
        Task {
            do {
                let name = try await recognitionService.identifyPlant(from: image)
                
                await MainActor.run {
                    self.detectedName = name
                    self.isLoading = false
                    self.navigateToResult = true
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to identify plant. Please try again."
                    self.showError = true
                }
            }
        }
    }
}

#Preview {
    ScanView(
        service:  MockPlantRecognitionService()
    )
        .environmentObject(HomeViewModel())
}
