import SwiftUI

struct MainView: View {
    @StateObject private var cameraController = CameraController()
    @StateObject private var result = PredictionResult()

    @State private var selectedImage: UIImage?
    @State private var showPhotoPicker = false
    @State private var navigateToSummary = false
    @State private var cropRectInView: CGRect = .zero
    
    var body: some View {
        ZStack {
            CameraView(prediction: $result.label, controller: cameraController)
                .coordinateSpace(name: "cameraPreview")

            CameraOverlayView(
                onCapture: {
                    cameraController.captureImage(cropRectInView: cropRectInView) { image, label, confidence in
                        print("Image captured: \(image != nil), label: \(label), confidence: \(confidence)")
                        
                        result.image = image
                        result.label = label
                        result.confidence = confidence
                        
                        print("Prediction label just set: \(result.label)")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            navigateToSummary = true
                        }
                    }
                },
                onToggleFlash: {
                    cameraController.toggleTorch()
                },
                onOpenGallery: {
                    showPhotoPicker = true
                },
                cropRectInView: $cropRectInView
            )
        }
//        .navigationTitle("Scan")
//        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $navigateToSummary) {
            SummaryView(
                result: result,
                navigateToSummary: $navigateToSummary
            )
            .presentationDetents([.fraction(0.80), .fraction(0.99)])
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(selectedImage: $selectedImage)
        }
    }
}
