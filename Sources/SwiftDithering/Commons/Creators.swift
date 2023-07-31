//  Created by Lugalu on 18/07/23.

import UIKit
import CoreGraphics
import Accelerate

/**
    Creates the CGContext and Image Data needed for other operations in case of  bytes per pixel be nil also calculates it as is needed for other operations.
    - Parameters:
     - cgImage: the cgImage that will be converted into context and image buffer the color space is kept
     - bytesPerPixel: override of bytes per pixel if nothing is provided the value is calculated based on bytes per row / width
     - width: the width of the image
     - height: the height of the image
    - Returns: A tuple containg the context, image buffer and bytes per pixel, remember to deallocate the image buffer once it's not needed
 */
func createContextAndData(cgImage: CGImage, bytesPerPixel: Int? = nil, width: Int, height: Int) throws -> (imageContext: CGContext, imageData: UnsafeMutablePointer<UInt8>, bytesPerPixel: Int){
  
    let colorSpace = cgImage.colorSpace!
    let bytesPerRow = cgImage.bytesPerRow
    let bytesPerPixel = bytesPerPixel ?? bytesPerRow / width
    let bitsPerComponent = cgImage.bitsPerComponent
    
    let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * bytesPerPixel)
    
    guard let imageContext = CGContext(data: imageData,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: bitsPerComponent,
                                 bytesPerRow: bytesPerRow,
                                 space: colorSpace,
                                       bitmapInfo: cgImage.bitmapInfo.rawValue
    )
    else {
        throw ImageErrors.failedToCreateContext(localizedDescription: "Context Creation failed! Please generate an issue in the github repository with the image.")
    }
    imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    return (imageContext, imageData, bytesPerPixel)
}

/**
    Creates a new CGImage with the color space modified to the destination format.
    - Parameters:
     - source: Original format of the Image
     - destination: Desired format of the image
     - image: the image that will be converted
    - Returns: the  CGImage with the new color space format
 */
internal func createCGImage(source: vImage_CGImageFormat, destination: vImage_CGImageFormat, image: CGImage) throws -> CGImage {
    
    let converter = try vImageConverter.make(sourceFormat: source, destinationFormat: destination)
    
    let sourceBuffer = try vImage_Buffer(cgImage: image)
    defer {
        sourceBuffer.free()

    }
    
    var destinationBuffer = try vImage_Buffer( size: sourceBuffer.size,
                                               bitsPerPixel: destination.bitsPerPixel)
    
    defer {
        destinationBuffer.free()
    }
    
    try converter.convert(source: sourceBuffer, destination: &destinationBuffer)
    
    let result = try destinationBuffer.createCGImage(format: destination)
    
    return result
}




