//
//  Test.swift
//  DefualtSource
//
//  Created by darktech4 on 10/10/2023.
//

import SwiftUI
import UIKit
import Vision

struct DrawingBoundingBoxViewWrapper: UIViewRepresentable {
    @Binding var predictedObjects: [VNRecognizedObjectObservation]

    func makeUIView(context: Context) -> DrawingBoundingBoxView {
        let view = DrawingBoundingBoxView()
        return view
    }

    func updateUIView(_ uiView: DrawingBoundingBoxView, context: Context) {
        uiView.predictedObjects = predictedObjects
    }
}

struct VideoPreviewView: UIViewRepresentable {
    @ObservedObject var viewModel: Yolov5ViewModel

    func makeUIView(context: Context) -> UIView {
        let videoPreview = UIView()

        // Create an AVCaptureVideoPreviewLayer
        if let videoCapture = viewModel.videoCapture, let previewLayer = videoCapture.previewLayer {
            videoPreview.layer.addSublayer(previewLayer)
            previewLayer.frame = videoPreview.frame
        }

        return videoPreview
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let videoCapture = viewModel.videoCapture, let previewLayer = videoCapture.previewLayer {
            uiView.layer.sublayers = nil // Clear any previous sublayers
            uiView.layer.addSublayer(previewLayer)
            previewLayer.frame = uiView.frame
        }
    }
}
