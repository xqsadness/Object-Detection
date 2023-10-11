//
//  PhotoListView.swift
//  DefualtSource
//
//  Created by darktech4 on 06/10/2023.
//

import SwiftUI

struct PhotoListView: View {
    @StateObject var viewModel = PhotoListViewModel()
    @StateObject var faceDetector = DetectFaces()
    @State var isShowCamera = false
    
    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    Text("Photo")
                        .font(.title)
                        .foregroundColor(.text)
                    
                    Spacer()
                    
                    NavigationLink{
                        DuplicateView()
                    }label: {
                        Text("Duplicate")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    NavigationLink{
                       LiveFeedYolov5View()
//                        isShowCamera.toggle()
                    }label: {
                        Image(systemName: "camera")
                            .imageScale(.large)
                    }
                    
                }
                .hAlign(.leading)
                .padding(.horizontal)
                .padding(.bottom)
//                .sheet(isPresented: $isShowCamera) {
//                    LiveFeedView()
//                }
                
                ScrollView(showsIndicators: false){
                    ForEach(viewModel.groupedPhotos.keys.sorted().reversed(), id: \.self) { date in
                        VStack{
                            Text(formatDate(date))
                                .font(.title3)
                                .foregroundColor(.text)
                                .hAlign(.leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ], spacing: 5) {
                                ForEach(viewModel.groupedPhotos[date]!, id: \.localIdentifier) { photo in
                                    PhotoRowView(photo: photo, viewModel: viewModel, classifier: ImageClassifierVMD(),faceDetector: faceDetector)
                                }
                            }
                        }
                        
                    }
                }
                .refreshable {
                    viewModel.loadPhotos()
                }
            }
        }
        .onAppear {
            viewModel.loadPhotos()
        }
    }
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
