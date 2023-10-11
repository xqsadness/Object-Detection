//
//  Yolov5ViewModel.swift
//  DefualtSource
//
//  Created by darktech4 on 10/10/2023.
//

import UIKit
import Vision
import SwiftUI


class Yolov5ViewModel: ObservableObject, VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        if !self.isInferencing, let pixelBuffer = pixelBuffer {
            self.isInferencing = true
            
            // Start measuring inference time
            let inferenceStartTime = Date()
            
            // Perform inference
            self.predictUsingVision(pixelBuffer: pixelBuffer)
            
            DispatchQueue.main.async {
                // Calculate inference time
                let inferenceTime = Date().timeIntervalSince(inferenceStartTime) * 1000.0
//                self.inferenceText = String(format: "Inference: %.2f ms", inferenceTime)
                
                // Calculate and update FPS
                let executionTime = Date().timeIntervalSince(self.lastExecution) * 1000.0
                self.lastExecution = Date()
                let fps = Int(1000.0 / executionTime)
//                self.fpsText = "FPS: \(fps)"
                
                
                self.maf1.append(element: Int(inferenceTime*1000.0))
                self.maf2.append(element: Int(executionTime*1000.0))
                self.maf3.append(element: fps)
                
                self.inferenceText = "inference: \(self.maf1.averageValue) ms"
                self.executionText = "execution: \(self.maf2.averageValue) ms"
                self.fpsText = "\(self.maf3.averageValue)"
            }
            
        }
    }
    
    // MARK: - Core ML model
    lazy var objectDetectionModel = { return try? yolov5n() }()
    
    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    var isInferencing = false
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!
    let semaphore = DispatchSemaphore(value: 1)
    var lastExecution = Date()
    
    // MARK: - ViewModel Properties
    @Published var predictions: [VNRecognizedObjectObservation] = []
    
    @Published var inferenceText: String = ""
    @Published var executionText: String = ""
    @Published var fpsText: String = ""
    
    @Published var maf1 = MovingAverageFilter()
    @Published var maf2 = MovingAverageFilter()
    @Published var maf3 = MovingAverageFilter()
    
    // MARK: - ViewModel Methods
    func setUpModel() {
        guard let objectDetectionModel = objectDetectionModel else { fatalError("Failed to load the model") }
        if let visionModel = try? VNCoreMLModel(for: objectDetectionModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError("Failed to create vision model")
        }
    }
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            if success {
                self.videoCapture.start()
            }
        }
    }
    
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        self.semaphore.wait()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let predictions = request.results as? [VNRecognizedObjectObservation] {
                self.predictions = predictions
                self.isInferencing = false
            } else {
                self.isInferencing = false
            }
            self.semaphore.signal()
        }
    }
}

class MovingAverageFilter {
    private var arr: [Int] = []
    private let maxCount = 10
    
    public func append(element: Int) {
        arr.append(element)
        if arr.count > maxCount {
            arr.removeFirst()
        }
    }
    
    public var averageValue: Int {
        guard !arr.isEmpty else { return 0 }
        let sum = arr.reduce(0) { $0 + $1 }
        return Int(Double(sum) / Double(arr.count))
    }
}


