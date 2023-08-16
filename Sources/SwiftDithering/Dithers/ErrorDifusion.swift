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
            assigner = assignStuckiResults
            looper = genericImageLooper
            
        case .fastFloydSteinberg:
            assigner = assignFloydResults
            looper = genericFastImageLooper
            
        case .fastStucki:
            assigner = assignStuckiResults
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

/**
 A generic application of Error difusion it just calculates the basic values that are equal to all styles
 - Parameters:
    - imageData: Image buffer to be modified
    - width: total width of the image
    - height: total height of the image
    - bytesPerPixel: number of bytes of each pixel on screen is multiplied with the rest of the index as an offset
    - numberOfBits: number of desired bits to reduce the color pallete
    - isQuantizationInverted: inverts the order of quantization producing interesting results
    - assigner: the brain of the error difusion this determines how is assigned and spread
    - looper: the type of looper used to access each pixel.
 */
internal func genericErrorDifusion(imageData: inout UnsafeMutablePointer<UInt8>,
                                                width: Int,
                                                height: Int,
                                                bytesPerPixel: Int,
                                                numberOfBits: Int,
                                                isQuantizationInverted: Bool,
                                                assigner:  @escaping (inout UnsafeMutablePointer<UInt8>,
                                                                      (Int,Int),
                                                                      (Int,Int),
                                                                      colorTuple,
                                                                      colorTuple,
                                                                      Int) -> Void,
                                            looper: (inout UnsafeMutablePointer<UInt8>,
                                                     Int, Int,
                                                     @escaping (_ imageData: inout UnsafeMutablePointer<UInt8>,
                                                                _ x: Int,
                                                                _ y: Int) -> Void) -> Void) {
         #if DEBUG
             let start = CFAbsoluteTimeGetCurrent()
         #endif
    
    looper(&imageData, width, height){ (imageData,x, y) in

        let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
        let oldColor = getRgbFor(index: index, inData: imageData)
        let quantitizedValue = quantitizeRGB(imageData: imageData, index: index, numberOfBits: numberOfBits)
        let error = makeQuantizationError(originalColor: oldColor, quantitizedColor: quantitizedValue, isInverted: isQuantizationInverted)

        let pos = (x, y)
        let size = (width, height)

        assigner(&imageData, pos, size, convertOriginalColor(quantitizedValue), error, bytesPerPixel)
    }
    
         #if DEBUG
             print("Finished floy dithering totalTime: \(CFAbsoluteTimeGetCurrent() - start)")
         #endif

}
