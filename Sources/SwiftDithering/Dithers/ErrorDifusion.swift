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
    func applyErrorDifusion(withType diffusionType: ErrorDifusionTypes, nearestFactor: Int = 2) throws -> UIImage{
        guard let cgImageTemp = self.cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available")}
        
        let cgImage = try convertColorSpaceToRGB(cgImageTemp)
        
        let width = cgImage.width
        let height = cgImage.height

        
        let quantizatorImage = try convertColorSpaceToGrayScale(cgImage)
        let (_,quantitizedImageData, quantitizedBytesPerPixel) = try prepareQuantization(grayScaleImage: quantizatorImage)
        let rgbQuantizator = try convertColorSpaceToRGB(quantizatorImage)
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage, width: width, height: height)
        
        defer {
            imageData.deallocate()
            quantitizedImageData.deallocate()
        }

        switch diffusionType {
        case .floydSteinberg:
            //modifyFloydImageData(&imageData, grayImageData: quantitizedImageData, width: width, height: height, bytesPerPixel: bytesPerPixel, grayBytesPerPixel: quantitizedBytesPerPixel, nearestFactor: nearestFactor)
            floydDither(finalImageData: &imageData, quantitizedImageData: quantitizedImageData, width: width, height: height, finalImageBytesPerPixel: bytesPerPixel, quantitizedBytesPerPixel: quantitizedBytesPerPixel)
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
    
    func floydDither(finalImageData: inout UnsafeMutablePointer<UInt8>, quantitizedImageData: UnsafeMutablePointer<UInt8>, width: Int, height: Int, finalImageBytesPerPixel finalBytesPerPixel: Int, quantitizedBytesPerPixel: Int){
        
        for y in 0..<height{
            for x in 0..<width{
                let finalImageIndex = indexCalculator(x: x, y: y, width: width, bytesPerPixel: finalBytesPerPixel)
                let quantitizedIndex = indexCalculator(x: x, y: y, width: width, bytesPerPixel: quantitizedBytesPerPixel)
                let quantitizedValue = Int(quantitizedImageData[quantitizedIndex])
                
                if quantitizedValue != 0 && quantitizedValue != 255 {
                    
                }
                
                var error = (
                    r: Int(finalImageData[finalImageIndex]) - quantitizedValue,
                    g: Int(finalImageData[finalImageIndex + 1]) - quantitizedValue,
                    b: Int(finalImageData[finalImageIndex + 2]) - quantitizedValue
                )
                
                assignNewColorsTo(imageData: &finalImageData, index: finalImageIndex, colors: (error.r,error.g,error.b))
                
                if x + 1 < width{
                    applyQuantization(&finalImageData, error, x: x + 1, y: y, width: width, bytesPerPixel: finalBytesPerPixel)
                }
                if y + 1 < height{
                    if x - 1 >= 0 {
                        applyQuantization(&finalImageData, error, x: x - 1, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, multiplier: 3)
                    }
                    applyQuantization(&finalImageData, error, x: x, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, multiplier: 5)
                    
                    if x + 1 < width{
                        applyQuantization(&finalImageData, error, x: x + 1, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, multiplier: 1)
                    }
                }
                
            }
        }
        
        
        
    }
    
    
}
