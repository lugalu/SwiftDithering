//  Created by Lugalu on 18/07/23.

import UIKit

public enum ErrorDifusionTypes{
    /**
        Standart Floyd-Steinberg dither algorithm runs on only one thread as originally intended produces the most accurate version, but can be very slow
     */
    case floydSteinberg
    /**
        Standart Stucki dither algorithm runs on only one thread as originally intended produces the most accurate version, but can be very slow
     */
    case stucki
    /**
        Floyd-Steinberg dither algorithm runs on multiple Threads fast but not accurate in certain scenarios
        - Warning: Some images Get really distorted with this option enabled, only worth for big images.
     */
    case fastFloydSteinberg
    /**
        Stucki dither algorithm runs on multiple Threads fast but not accurate in certain scenarios
        - Warning: Some images Get really distorted with this option enabled, only worth for big images.
     */
    case fastStucki
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
    func applyErrorDifusion(withType diffusionType: ErrorDifusionTypes, nearestFactor: Int = 2, numberOfBits: Int = 2, isQuantizationInverted: Bool = false) throws -> UIImage {
        guard var cgImage = self.cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available") }
        
        cgImage = try convertColorSpaceToRGB(cgImage)
        
        
        let width = cgImage.width
        let height = cgImage.height
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage, width: width, height: height)
        
        defer {
            imageData.deallocate()
        }

        var assigner: (inout UnsafeMutablePointer<UInt8>, (Int,Int), (Int,Int), colorTuple, colorTuple, Int) -> Void
        var looper: (inout UnsafeMutablePointer<UInt8>, Int, Int, @escaping (_ imageData: inout UnsafeMutablePointer<UInt8>, _ x: Int, _ y: Int) -> Void) -> Void
        
        switch diffusionType {
        case .floydSteinberg:
            assigner = assignFloydResults
            looper = genericImageLooper
            
        case .stucki:
            assigner = stuckiLogic
            looper = genericImageLooper
            
        case .fastFloydSteinberg:
            assigner = assignFloydResults
            looper = genericFastImageLooper
            
        case .fastStucki:
            assigner = stuckiLogic
            looper = genericFastImageLooper
            
        }
        
        genericErrorDifusion(imageData: &imageData, width: width, height: height, bytesPerPixel: bytesPerPixel, numberOfBits: numberOfBits, isQuantizationInverted: isQuantizationInverted, assigner: assigner, looper: looper)
        
        guard let outputCGImage = imageContext.makeImage()  else {
            throw ImageErrors
            .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")

        }
        
        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
 
    
    
}
