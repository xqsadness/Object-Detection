//
//  LiveFeedYolov5View.swift
//  DefualtSource
//
//  Created by darktech4 on 10/10/2023.
//

import SwiftUI

struct LiveFeedYolov5View: View {
    @StateObject private var viewModel = Yolov5ViewModel()

    var body: some View {
        VStack {
            ZStack {
                VideoPreviewView(viewModel: viewModel)
                DrawingBoundingBoxViewWrapper(predictedObjects: $viewModel.predictions)
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height / 1.5)

            VStack{
                Text("Inference: \(viewModel.inferenceText)")
                Text("Execution: \(viewModel.executionText)")
                Text("FPS: \(viewModel.fpsText)")

                List(viewModel.predictions, id: \.self) { prediction in
                    let confidence = prediction.confidence

                    HStack {
                        Text(prediction.label ?? "N/A")
                        Spacer()
                        Text(String(format: "%.3f", confidence))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height / 2.5)
        }
        .onAppear {
            viewModel.setUpModel()
            viewModel.setUpCamera()
        }
    }
}
