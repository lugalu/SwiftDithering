//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import UIKit

public enum ErrorDifusionTypes{
    case floydSteinberg
    case stucki
}

public extension UIImage{
    /**
        Applies ErrorDifusion  this dither support colors on the RGB space and the colors can be turned off.
        The image must contain an CGImage to be processed, and this method can cause crashes that Cannot be throw becasue of the draw function.
        - Parameters:
          - withType: The type of Error difusion check;
          - spread: Max distance between the calculated value and the original value by default  equals to 1.0, Warning: the value isn't clamped so going above the threshold can cause artifacts;
          - bytesPerPixel: The image bytes can be tweaked for different results, going too low or too high can cause crashes, the default value is calculated between the division of bytesPerRow/Width
        - Returns: UIImage with the dithering applied
     */
    /// - Tag: applyErrorDifusion
    func applyErrorDifusion(withType diffusionType: ErrorDifusionTypes, isColored: Bool = false, nearestFactor: Int = 2) throws -> UIImage{
        guard let cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available")}
        let width = cgImage.width
        let height = cgImage.height
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage, width: width, height: height)
        defer {
            imageData.deallocate()
        }
        
        switch diffusionType {
        case .floydSteinberg:
            modifyFloydImageData(&imageData, isColored: isColored, width: width, height: height, bytesPerPixel: bytesPerPixel, nearestFactor: nearestFactor)
            
        case .stucki:
            //TODO: Implement Stucki type.
            return UIImage(systemName: "pencil")!
            
        }
        
        guard let outputCGImage = imageContext.makeImage()  else {
            throw ImageErrors
            .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
            
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    

}
