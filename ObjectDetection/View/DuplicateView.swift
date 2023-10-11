//
//  DuplicateView.swift
//  YourApp
//
//  Created by YourName on 05/10/2023.
//

import SwiftUI
import Photos

struct DuplicateView: View {
    @State var asset: [[PHAsset]] = []
    @StateObject var viewModel = PhotoListViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            ScrollView{
                if viewModel.listDuplicatesPhotos.isEmpty{
                    Text("You don't have any Duplicate Photos!")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "000000"))
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 3)
                }else{
                    ForEach(viewModel.listDuplicatesPhotos, id: \.self) { assetGroup in
                        ScrollView(.horizontal, showsIndicators: false){
                            LazyHStack{
                                ForEach(assetGroup, id: \.localIdentifier){ photo in
                                    ItemDuplicateView(assetGroup: assetGroup, photo: photo, viewModel: viewModel)
                                }
                            }
                        }
                        .onAppear{
                            for i in assetGroup{
                                viewModel.loadImage(fromAsset: i)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    removeDuplicatePhotos()
                } label: {
                    Text("Clean")
                }
            }
        }
        .onAppear{
            viewModel.getDuplcatePhoto()
        }
    }
    
    func removeDuplicatePhotos() {
        let allPhotos = viewModel.listDuplicatesPhotos
        
        var list: [PHAsset] = []
        for photoGroup in allPhotos {
            var listModified = photoGroup // Remove the first asset from the group
            listModified.removeFirst()
            for i in listModified {
                list.append(i)
            }
        }
        
        let library = PHPhotoLibrary.shared()
        
        library.performChanges({
            let assetsToDelete = NSArray(array: list)
            PHAssetChangeRequest.deleteAssets(assetsToDelete)
        }) { success, error in
            if success {
                print("Assets deleted successfully")
                self.viewModel.getDuplcatePhoto()
            } else {
                print("Error deleting assets: \(String(describing: error))")
            }
        }
    }
}


struct ItemDuplicateView: View {
    @State var assetGroup: [PHAsset]
    @State var photo: PHAsset
    @StateObject var viewModel: PhotoListViewModel
    
    var body: some View {
        if photo.localIdentifier != "" {
            if let image = viewModel.images[photo.localIdentifier] {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 130, height: 130)
                    .scaledToFill()
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
    }
}
