//
//  PhotoListViewModel.swift
//  DefualtSource
//
//  Created by darktech4 on 06/10/2023.
//

import Foundation
import Photos
import UIKit


class PhotoListViewModel: ObservableObject {
    @Published var photos: [PHAsset] = []
    @Published var images: [String: UIImage] = [:]
    @Published var groupedPhotos: [Date: [PHAsset]] = [:]
    @Published var isShowingInfo: Bool = false
    @Published var listDuplicatesPhotos: [[PHAsset]] = []
    
    func loadPhotos() {
        DispatchQueue.main.async {
            let photos = ImageManager().fetchPhotos()
            let groupedPhotos = Dictionary(grouping: photos) { photo in
                guard let creationDate = photo.creationDate else {
                    return Date() // If no creation date is available, use today's date as a fallback.
                }
                return Calendar.current.startOfDay(for: creationDate)
            }
            self.groupedPhotos = groupedPhotos
            self.photos = photos
        }
    }
    
    func loadImage(fromAsset asset: PHAsset) {
        ImageManager().loadImage(fromAsset: asset) { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.images[asset.localIdentifier] = image
                }
            }
        }
    }
    
    func getDuplcatePhoto(){
        ImageManager().getDuplicatePhotosByGroup { photos in
            DispatchQueue.main.async {
                self.listDuplicatesPhotos = photos
            }
        }
    }
    
    func deletePhoto(_ photo: PHAsset) {
        ImageManager().deletePhotos(photosToDelete: [photo]) { success, error in
            if success {
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(of: photo) {
                        self.photos.remove(at: index)
                        self.loadPhotos()
                        LocalNotification.shared.message("Delete Sucsess", .success)
                    }
                }
            } else {
                // handle error if needed
                LocalNotification.shared.message("Delete Faild", .error)
            }
        }
    }
}
