import Foundation
import UIKit

class CameraController: ObservableObject {
    var coordinator: CameraView.Coordinator?
    
    func toggleTorch() {
        coordinator?.toggleTorch()
    }
    
    func captureImage(cropRectInView: CGRect, completion: @escaping (UIImage?, String, Double) -> Void) {
        coordinator?.captureStillImage(cropRectInView: cropRectInView, completion: completion)
    }
}

class PredictionResult: ObservableObject {
    @Published var image: UIImage?
    @Published var label: String = ""
    @Published var confidence: Double = 0.0
}
