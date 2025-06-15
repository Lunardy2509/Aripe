import SwiftUI
import AVFoundation
import Vision
import CoreML

struct CameraView: UIViewRepresentable {
    @Binding var prediction: String
    var controller: CameraController

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(prediction: $prediction)
        controller.coordinator = coordinator
        return coordinator
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        context.coordinator.setupCamera(in: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        private let session = AVCaptureSession()
        private var previewLayer: AVCaptureVideoPreviewLayer?
        private var model: VNCoreMLModel?
        private var lastSampleBuffer: CMSampleBuffer?
        @Binding var prediction: String

        init(prediction: Binding<String>) {
            _prediction = prediction
            if let coreMLModel = try? AppleRipenessModel(configuration: MLModelConfiguration()).model,
               let visionModel = try? VNCoreMLModel(for: coreMLModel) {
                self.model = visionModel
            } else {
                self.model = nil
                print("❌ Failed to load CoreML model.")
            }
        }

        func setupCamera(in view: UIView) {
            session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                print("❌ Camera input setup failed.")
                return
            }
            session.addInput(input)

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame = UIScreen.main.bounds
            DispatchQueue.main.async {
                view.layer.insertSublayer(preview, at: 0)
            }
            self.previewLayer = preview

            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            self.lastSampleBuffer = sampleBuffer
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                  let model = model else {
                return
            }

            let request = VNCoreMLRequest(model: model) { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation],
                      let bestResult = results.first else {
                    return
                }

                DispatchQueue.main.async {
                    self.prediction = "\(bestResult.identifier) (\(Int(bestResult.confidence * 100))%)"
                }
            }

            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("❌ Vision request failed: \(error)")
            }
        }

        func toggleTorch() {
            guard let device = AVCaptureDevice.default(for: .video),
                  device.hasTorch else {
                print("⚠️ Torch not available.")
                return
            }

            do {
                try device.lockForConfiguration()
                device.torchMode = (device.torchMode == .on) ? .off : .on
                device.unlockForConfiguration()
            } catch {
                print("❌ Torch control failed: \(error)")
            }
        }

        func convertViewRectToImageRect(viewRect: CGRect, previewLayer: AVCaptureVideoPreviewLayer, imageSize: CGSize) -> CGRect {
            let metadataOutputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: viewRect)
            return CGRect(
                x: metadataOutputRect.origin.x * imageSize.width,
                y: metadataOutputRect.origin.y * imageSize.height,
                width: metadataOutputRect.size.width * imageSize.width,
                height: metadataOutputRect.size.height * imageSize.height
            )
        }

        func captureStillImage(cropRectInView: CGRect, completion: @escaping (UIImage?, String, Double) -> Void) {
            guard let buffer = lastSampleBuffer,
                  let imageBuffer = CMSampleBufferGetImageBuffer(buffer),
                  let model = model else {
                completion(nil, "No Frame Detected", 0.0)
                return
            }

            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext()

            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                completion(nil, "Failed to create image", 0.0)
                return
            }

            let fullImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: exifOrientationFromDeviceOrientation())

            guard let previewLayer = previewLayer else {
                completion(nil, "Missing preview layer", 0.0)
                return
            }

            // Convert SwiftUI view-space cropRect to metadata output rect
            let metadataRect = previewLayer.metadataOutputRectConverted(fromLayerRect: cropRectInView)
            
            // Convert metadata output rect (0-1) to CIImage extent (in pixels)
            var cropRect = CGRect(
                x: metadataRect.origin.x * ciImage.extent.width,
                y: (1 - metadataRect.origin.y - metadataRect.height) * ciImage.extent.height, // Flip Y axis
                width: metadataRect.size.width * ciImage.extent.width,
                height: metadataRect.size.height * ciImage.extent.height
            )
            
            // Apply upward offset (positive dy moves down, negative dy moves up)
            let horizontalOffset: CGFloat = -110
            let verticalOffset: CGFloat = 0
            cropRect = cropRect.offsetBy(dx: horizontalOffset, dy: verticalOffset)

            // Make sure we don't go out of bounds
            cropRect = cropRect.intersection(ciImage.extent)

            guard let croppedCG = cgImage.cropping(to: cropRect) else {
                completion(fullImage, "Cropping failed", 0.0)
                return
            }

            let croppedImage = UIImage(cgImage: croppedCG, scale: fullImage.scale, orientation: fullImage.imageOrientation)

            let handler = VNImageRequestHandler(cgImage: croppedCG, options: [:])
            let request = VNCoreMLRequest(model: model) { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    DispatchQueue.main.async {
                        completion(croppedImage, "Prediction failed", 0.0)
                    }
                    return
                }

                DispatchQueue.main.async {
                    completion(croppedImage, topResult.identifier, Double(topResult.confidence))
                }
            }

            do {
                try handler.perform([request])
            } catch {
                print("❌ Error running ML request: \(error)")
                completion(croppedImage, "Prediction error", 0.0)
            }
        }

        func exifOrientationFromDeviceOrientation() -> UIImage.Orientation {
            switch UIDevice.current.orientation {
            case .portraitUpsideDown: return .left
            case .landscapeLeft:      return .upMirrored
            case .landscapeRight:     return .down
            case .portrait:           return .right
            default:                  return .right
            }
        }
    }
}
