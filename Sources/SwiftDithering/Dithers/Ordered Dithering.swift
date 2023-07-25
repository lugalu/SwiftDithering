//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import UIKit

/**
 This enum contains all the information regarding Bayer matrices from size to matrix values.
 */
public enum BayerSizes: Int{
    case bayer2x2 = 2
    case bayer4x4 = 4
    case bayer8x8 = 8
    
    
    func getBayerMatrix() -> [[UInt8]]{
        switch self{
        case .bayer2x2:
            return [
                [0, 2],
                [3, 1]
            ]
        case .bayer4x4:
            return [
                [0, 8, 2, 10],
                [12, 4, 14, 6],
                [3, 11, 1, 9],
                [15, 7, 13, 5]
            ]
        case .bayer8x8:
            return [
                [ 0, 32,  8, 40,  2, 34, 10, 42],
                [48, 16, 56, 24, 50, 18, 58, 26],
                [12, 44,  4, 36, 14, 46,  6, 38],
                [60, 28, 52, 20, 62, 30, 54, 22],
                [ 3, 35, 11, 43,  1, 33,  9, 41],
                [51, 19, 59, 27, 49, 17, 57, 25],
                [15, 47,  7, 39, 13, 45,  5, 37],
                [63, 31, 55, 23, 61, 29, 53, 21]
            ]
        }
    }
}

public extension UIImage{
    /**
        Applies Ordered Dithering, also known as Bayer dithering to the image,  this dither support colors on the RGB space.
        The image must contain an CGImage to be processed, and this method can cause crashes that Cannot be throw becasue of the draw function.
        - Parameters:
          - bayerSize: The Matrix size used to calculate the color difference;
          - spread: Max distance between the calculated value and the original value by default  equals to 1.0, Warning: the value isn't clamped so going above the threshold can cause artifacts;
          - bytesPerPixel: The image bytes can be tweaked for different results, going too low or too high can cause crashes, the default value is calculated between the division of bytesPerRow/Width
        - Returns: UIImage with the dithering applied
     */
    /// - Tag: applyOrderedDither
    func applyOrderedDither(withSize bayerSize: BayerSizes, spread: Double = 1.0, bytesPerPixel: Int? = nil) throws -> UIImage{
        guard let cgImageTemp = self.cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available") }
        
        let cgImage = try convertColorSpace(cgImageTemp)
        
        let width = cgImage.width
        let height = cgImage.height
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage,
                                                           bytesPerPixel: bytesPerPixel,
                                                           width: width,
                                                           height: height)

        modifyOrderedImageData(&imageData,
                        bayerSize: bayerSize,
                        width: width,
                        height: height,
                        spread: spread,
                        bytesPerPixel: bytesPerPixel)
        
        guard let outputCGImage = imageContext.makeImage()  else {
            throw ImageErrors
            .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
            
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    

    
}

