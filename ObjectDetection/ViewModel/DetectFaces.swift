//
//  DetectFace.swift
//  DefualtSource
//
//  Created by darktech4 on 04/10/2023.
//

import UIKit
import Vision

class DetectFaces: ObservableObject{
    var image: UIImage = UIImage()
    
    @Published var outputImage: UIImage?
    
    var detectedFaces: [VNFaceObservation] = [VNFaceObservation()]
    
    /*
     Detects faces in a given UIImage and invokes a handler to process the results.
     - Parameter image: The UIImage to detect faces.
     */
    func detectFaces(in image: UIImage){
        guard let ciImage = CIImage(image: image) else{
            fatalError("err")
        }
        let request = VNDetectFaceRectanglesRequest(completionHandler: self.handleFacesData)
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([request])
        }catch let err{
            print("faild \(err.localizedDescription)")
        }
    }
    
    /*
     Handles the results of a face detection request.
     - Parameter request: A VNRequest containing the results of the face detection.
     - Parameter err: An optional Error object in case there was an error in the request.
     */
    
    func handleFacesData(request: VNRequest, err: Error?){
        DispatchQueue.main.async {
            guard let request = request.results as? [VNFaceObservation] else{
                return
            }
            self.detectedFaces = request
            for faces in self.detectedFaces{
                self.addRect(result: faces)
            }
            
            self.outputImage = self.image
        }
    }
    
    /*
     Draw a rectangle in an image to highlight a detected face.
     - Parameter result: The result of VNFaceObservation containing the bounding box of the detected face.
     - Output: An updated image with a red rectangle drawn around the detected face.
     */
    func addRect(result: VNFaceObservation){
        let imageSize = CGSize(width: image.size.width, height: image.size.height)
        
        let boundingBox = result.boundingBox
        let scaledBox = CGRect(x: boundingBox.origin.x * imageSize.width, y: (1 - boundingBox.origin.y - boundingBox.size.height) * imageSize.height, width: boundingBox.size.width * imageSize.width, height: boundingBox.size.height * imageSize.height)
        
        let normalLizedRect = VNNormalizedRectForImageRect(scaledBox, Int(imageSize.width), Int(imageSize.height))
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(5.0)
        context.stroke(CGRect(x: normalLizedRect.origin.x * imageSize.width, y: normalLizedRect.origin.y * imageSize.height, width: normalLizedRect.size.width * imageSize.width, height: normalLizedRect.size.height * imageSize.height))
        
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
}
