//
//  ImageManager.swift
//  DefualtSource
//
//  Created by darktech4 on 06/10/2023.
//

import Photos
import UIKit


class ImageManager {
    /*
     Delete a list of images.
     - Parameter photosToDelete: An array of PHAsset objects the images to delete.
     - Parameter completion:
     + success: A boolean value indicating whether the deletion was successful.
     + error: Error object that contains information about the failure
     */
    func deletePhotos(photosToDelete: [PHAsset], completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(photosToDelete as NSFastEnumeration)
        }, completionHandler: { success, error in
            if success {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        })
    }
    
    /*
     Fetch all images from the photo library.
     - Returns: An array of PHAsset objects the fetched images.
     */
    func fetchPhotos() -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var photos: [PHAsset] = []
        fetchResult.enumerateObjects { (asset, _, _) in
            photos.append(asset)
        }
        return photos
    }
    
    /*
     Load an image from a PHAsset.
     - Parameter asset: A PHAsset object the image to load.
     - Parameter completion: The UIImage parameter will contain the loaded image if successful, or nil if there was an error.
     */
    func loadImage(fromAsset asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .none
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: requestOptions) { (image, _) in
            completion(image)
        }
    }
    
    /*
     Get duplicate photos grouped by hash value.
     - Parameter completion: A closure that takes an array contains a group of duplicate PHAsset objects based on hash value.
     */
    func getDuplicatePhotosByGroup(completion: @escaping ([[PHAsset]]) -> Void) {
        let allPhotos = fetchPhotos()
        var duplicatesByHash = [Int: [PHAsset]]()
        
        for asset in allPhotos {
            guard asset.mediaType == .image else {
                continue
            }
            
            if let hashValue = hashValue(for: asset) {
                if var assetsWithSameHash = duplicatesByHash[hashValue] {
                    assetsWithSameHash.append(asset)
                    duplicatesByHash[hashValue] = assetsWithSameHash
                } else {
                    duplicatesByHash[hashValue] = [asset]
                }
            }
        }
        
        let duplicates = duplicatesByHash.filter { $0.value.count > 1 }.values.map { $0 }
        
        DispatchQueue.main.async {
            completion(duplicates)
        }
    }
    
    /* Calculate a hash value for a PHAsset
     - Parameter asset: The PHAsset for which to calculate the hash value.
     - Returns: An Int hash value uniquely the asset.
     */
    func hashValue(for asset: PHAsset) -> Int? {
        var hasher = Hasher()
        
        // get value from PHAsset and hash
        if let imageData = getImageData(for: asset) {
            hasher.combine(imageData)
        }
        
        return hasher.finalize()
    }
    
    /**
     Retrieves image data for a given `PHAsset` using `PHImageManager`.
     - Parameters:
     - asset: The `PHAsset` for which to fetch image data.
     - Returns: Image data in the form of `Data` if available, or `nil` if there was an error or no data could be retrieved.
     */
    func getImageData(for asset: PHAsset) -> Data? {
        // use PHImageManager to get value from PHAsset
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var imageData: Data?
        
        imageManager.requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, _, _, _) in
            if let data = data {
                imageData = data
            }
        }
        
        return imageData
    }
}

extension PHAsset {
    func getAssetThumbnail() -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        option.deliveryMode = .fastFormat
        option.resizeMode = .fast
        manager.requestImage(for: self,
                             targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight),
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: {(result, info) -> Void in
            if let result = result {
                thumbnail = result
            }
            else{
                if let imageDefault = UIImage(named: "img-default") {
                    thumbnail = imageDefault
                }
            }
        })
        return thumbnail
    }
    
    func getAssetThumbnailOpportunistic() -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        option.deliveryMode = .opportunistic
        manager.requestImage(for: self,
                             targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight),
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: {(result, info) -> Void in
            if let result = result {
                thumbnail = result
            }
            else{
                if let imageDefault = UIImage(named: "img-default") {
                    thumbnail = imageDefault
                }
            }
        })
        return thumbnail
    }
}
