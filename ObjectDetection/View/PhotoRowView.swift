//
//  PhotoRowView.swift
//  DefualtSource
//
//  Created by darktech4 on 06/10/2023.
//

import SwiftUI
import Photos


struct PhotoRowView: View {
    var photo: PHAsset
    @ObservedObject var viewModel: PhotoListViewModel
    @ObservedObject var classifier: ImageClassifierVMD
    @ObservedObject var faceDetector: DetectFaces
    
    init(photo: PHAsset, viewModel: PhotoListViewModel,classifier: ImageClassifierVMD, faceDetector: DetectFaces) {
        self.photo = photo
        self.viewModel = viewModel
        self.classifier = classifier
        self.faceDetector = faceDetector
    }
    @State private var showingAlert = false
    @State private var number = ""
    @State var img: UIImage? = nil
    @State var load = true
    
    var body: some View {
        NavigationLink{
            DetailImageView(viewModel: viewModel, classifier: classifier, img: $img, showingAlert: $showingAlert, number: $number)
        }label: {
            HStack {
                if let image = img {
                    ZStack{
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130, height: 130)
                            .clipped()
                            .foregroundColor(.text)
                            .contextMenu{
                                Button{
                                    viewModel.deletePhoto(photo)
                                }label: {
                                    Text("Delete")
                                }
                                
                                Button{
                                    viewModel.isShowingInfo.toggle()
                                }label: {
                                    Text("Info")
                                }
                            }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 130, height: 130)
                        .foregroundColor(.text)
                        .contextMenu{
                            Button{
                                viewModel.deletePhoto(photo)
                            }label: {
                                Text("Delete")
                            }
                            
                            Button{
                                viewModel.isShowingInfo.toggle()
                            }label: {
                                Text("Info")
                            }
                        }
                }
            }
            //            .onAppear {
            //                viewModel.loadImage(fromAsset: photo)
            //            }
            .onAppear {
                img = photo.getAssetThumbnail()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if load{
                        var i : UIImage? = nil
                        DispatchQueue.global().async {
                            i = photo.getAssetThumbnailOpportunistic()
                            if load {
                                DispatchQueue.main.async {
                                    self.img = i
                                    //                                    viewModel.images[photo.localIdentifier] = self.img
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingInfo) {
                NavigationView {
                    PhotoInfoView(photo: photo, viewModel: viewModel)
                }
            }
            .padding(.horizontal)
            .hAlign(.leading)
            .frame(height: 130)
        }
    }   
}
