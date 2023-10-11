//
//  DetailImageView.swift
//  DefualtSource
//
//  Created by darktech4 on 06/10/2023.
//

import SwiftUI

struct DetailImageView: View {
    @ObservedObject var viewModel: PhotoListViewModel
    @ObservedObject var classifier: ImageClassifierVMD
    @StateObject var faceDetector = DetectFaces()
    @Binding var img: UIImage?
    @Binding var showingAlert: Bool
    @Binding var number: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = img {
                if faceDetector.outputImage != nil{
                    if !faceDetector.detectedFaces.isEmpty{
                        ZStack(alignment: .bottomLeading) {
                            Image(uiImage: faceDetector.outputImage!)
                                .resizable()
                                .scaledToFit()
                                .padding()
                            
                            Text("Detected \(faceDetector.detectedFaces.count) Faces ")
                                .bold()
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .padding()
                                .alignmentGuide(.bottom) { dimension in
                                    dimension[.bottom]
                                }
                                .alignmentGuide(.leading) { dimension in
                                    dimension[.leading]
                                }
                        }
                    }else{
                        ZStack(alignment: .bottomLeading) {
                            Image(uiImage: faceDetector.outputImage!)
                                .resizable()
                                .scaledToFit()
                                .padding()
                            
                            Text("No faces")
                                .bold()
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .padding()
                                .alignmentGuide(.bottom) { dimension in
                                    dimension[.bottom]
                                }
                                .alignmentGuide(.leading) { dimension in
                                    dimension[.leading]
                                }
                        }
                    }
                }else{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    
                    if let imageClass = classifier.imageClass {
                        Text(imageClass)
                            .bold()
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                            .padding()
                            .alignmentGuide(.bottom) { dimension in
                                dimension[.bottom]
                            }
                            .alignmentGuide(.leading) { dimension in
                                dimension[.leading]
                            }
                    } else {
                        Text(" NA")
                            .font(.caption)
                            .foregroundColor(.text)
                            .alignmentGuide(.bottom) { dimension in
                                dimension[.bottom]
                            }
                            .alignmentGuide(.leading) { dimension in
                                dimension[.leading]
                            }
                    }
                }
            }
        }
        .alert("Enter Predictions To Show", isPresented: $showingAlert) {
            TextField("Enter Predictions To Show", text: $number)
                .keyboardType(.numberPad)
            Button("OK", action: {
                classifier.predictionsToShow = Int(number) ?? 0
                if let image = img {
                    DispatchQueue.main.async {
                        classifier.classifyImage(image)
                    }
                }
            })
        } message: {
            Text("Enter Predictions To Show")
        }
        .vAlign(.top)
        .onAppear{
            if let image = img {
                DispatchQueue.main.async {
                    classifier.classifyImage(image)
                }
            }
        }
        .onDisappear{
            faceDetector.outputImage = nil
        }
        .navigationBarItems(trailing:
                                Menu("Option"){
            Button{
                faceDetector.outputImage = nil
                number = ""
                showingAlert = true
            }label: {
                Text("Predictions")
                    .foregroundColor(.blue)
            }
            
            Button{
                if let image = img {
                    faceDetector.image = image
                    faceDetector.detectFaces(in: image)
                }
            }label: {
                Text("Process Image")
                    .foregroundColor(.blue)
            }
        }
        )
    }
}
