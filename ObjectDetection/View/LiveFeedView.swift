//
//  Camera.swift
//  DefualtSource
//
//  Created by darktech4 on 05/10/2023.
//

import AVFoundation
import SwiftUI

// Create a SwiftUI view that wraps the AVCaptureViewController
struct LiveFeedView: View {
    var body: some View {
        LiveFeedViewController()
            .edgesIgnoringSafeArea(.all)
    }
}
