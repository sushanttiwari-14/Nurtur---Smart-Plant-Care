import SwiftUI

struct ScanView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: ScanViewModel
    @State private var showCamera = false
    
    var onPlantSaved: (() -> Void)?
    
    init(
        service: PlantRecognitionServiceProtocol,
        onPlantSaved: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: ScanViewModel(service: service)
        )
        self.onPlantSaved = onPlantSaved
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            if let image = viewModel.capturedImage {
                
                VStack(spacing: 12) {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(16)
                    
                    Button("Retake Photo") {
                        viewModel.capturedImage = nil
                        viewModel.detectedName = nil
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
            
            if viewModel.isLoading {
                ProgressView("Identifying plant...")
                    .padding()
            }
            
            Button("Open Camera") {
                showCamera = true
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.5 : 1)
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
        
        // ERROR ALERT
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        
        // NAVIGATION WHEN NAME EXISTS
        .navigationDestination(
            isPresented: Binding(
                get: { viewModel.detectedName != nil },
                set: { _ in viewModel.detectedName = nil }
            )
        ) {
            if let image = viewModel.capturedImage,
               let name = viewModel.detectedName {
                
                ScanResultView(
                    image: image,
                    plantName: name
                ) {
                    dismiss()
                    onPlantSaved?()
                }
                .environmentObject(homeViewModel)
            }
        }
        
        // CAMERA
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                viewModel.capturedImage = image
                
                Task {
                    await viewModel.recognizePlant()
                }
            }
        }
    }
}

#Preview {
    ScanView(
        service: MockPlantRecognitionService()
    )
    .environmentObject(HomeViewModel())
}
#Preview {
    ScanView(
        service:  MockPlantRecognitionService()
    )
        .environmentObject(HomeViewModel())
}
