//  Created by Lugalu on 18/07/23.

import UIKit



public extension UIImage {
    /**
     Applies Ordered Dithering, also known as Bayer dithering to the image,  this dither support colors on the RGB space.
     The image must contain an CGImage to be processed, and this method can cause crashes that Cannot be throw becasue of the draw function.
     - Parameters:
       - bayerSize: The Matrix size used to calculate the color difference;
       - spread: Max distance between the calculated value and the original value by default  equals to 1.0, Warning: the value isn't clamped so going above the threshold can cause artifacts;
       - isGrayScale: if the image should be converted to grayScale only
       - spread: how much deviation should exist when adding the threshold to each pixel recommended to be within 0-1
       - numberOfBits: if the image is colored how much colors you allow
     - Returns: UIImage with the dithering applied
     - Tag: applyOrderedDither
     */
    func applyOrderedDither(withSize bayerSize: BayerSizes, isBayerInverted: Bool = false, isGrayScale: Bool = false, spread: Double = 1.0, numberOfBits:Int = 2) throws -> UIImage {
        guard let cgImageBase = self.cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available") }
        
        var assigner: (inout UnsafeMutablePointer<UInt8>, Int, UInt8, Bool, Int) -> Void
        var cgImage: CGImage
        
        if isGrayScale {
            assigner = assignGrayScaleBayer
            cgImage = try convertColorSpaceToGrayScale(cgImageBase)
            
        }else {
            assigner = assignColoredBayer
            cgImage = try convertColorSpaceToRGB(cgImageBase)
            
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage,
                                                                                width: width,
                                                                                height: height)
        
        defer {
            imageData.deallocate()
        }
        
        genericBayer(&imageData,
                     bayerSize: bayerSize,
                     size: (width, height),
                     numberOfBits: numberOfBits,
                     bytesPerPixel: bytesPerPixel,
                     isBayerInverted: isBayerInverted,
                     assigner: assigner)
        
        guard let outputCGImage = imageContext.makeImage() else {
            throw ImageErrors
                .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
            
        }
        
        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
}
