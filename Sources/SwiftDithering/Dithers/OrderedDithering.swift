//  Created by Lugalu on 18/07/23.

import UIKit



public extension UIImage {
    /**
     Applies Ordered Dithering, also known as Bayer dithering to the image,  this dither support colors on the RGB space.
     The image must contain an CGImage to be processed, and this method can cause crashes that Cannot be throw becasue of the draw function.
     - Parameters:
     - bayerSize: The Matrix size used to calculate the color difference;
     - spread: Max distance between the calculated value and the original value by default  equals to 1.0, Warning: the value isn't clamped so going above the threshold can cause artifacts;
     - bytesPerPixel: The image bytes can be tweaked for different results, going too low or too high can cause crashes, the default value is calculated between the division of bytesPerRow/Width
     - Returns: UIImage with the dithering applied
     - Tag: applyOrderedDither
     */
    func applyOrderedDither(withSize bayerSize: BayerSizes, bytesPerPixel: Int? = nil, isBayerInverted: Bool = false) throws -> UIImage {
        guard let cgImageTemp = self.cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available") }
        
        let gray = try convertColorSpaceToGrayScale(cgImageTemp)
        //let cgImage = try convertColorSpaceToRGB(gray)
        
        
        let width = gray.width
        let height = gray.height
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: gray,
                                                                                bytesPerPixel: bytesPerPixel,
                                                                                width: width,
                                                                                height: height)
        
        defer {
            imageData.deallocate()
        }
        
        bayerDither(&imageData,
                    bayerSize: bayerSize,
                    width: width,
                    height: height,
                    bytesPerPixel: bytesPerPixel,
                    isBayerInverted: isBayerInverted
        )
        
        guard let outputCGImage = imageContext.makeImage() else {
            throw ImageErrors
                .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
            
        }
        
        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
}