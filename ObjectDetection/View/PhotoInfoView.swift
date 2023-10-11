//
//  PhotoInfoView.swift
//  DefualtSource
//
//  Created by darktech4 on 06/10/2023.
//

import SwiftUI
import Photos

struct PhotoInfoView: View {
    var photo: PHAsset
    @ObservedObject var viewModel: PhotoListViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Photo Info")
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                
                Text("Local Identifier: \(photo.localIdentifier)")
                Text("Creation Date: \(formatDate(photo.creationDate))")
                Text("mediaSubtypes: \(photo.mediaSubtypes.rawValue)")
                Text("mediaType: \(photo.mediaType.rawValue)")
                if let lo = photo.location{
                    Text("location: \(lo.course)")
                }
                Text("pixelWidth: \(photo.pixelWidth)")
                Text("pixelHeight: \(photo.pixelHeight)")
                Text("description: \(photo.description)")
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button("Done") {
            viewModel.isShowingInfo = false
        })
    }
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
