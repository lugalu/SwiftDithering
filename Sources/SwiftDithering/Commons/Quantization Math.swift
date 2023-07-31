//
//  File.swift
//  
//
//  Created by Lugalu on 30/07/23.
//

import Foundation
import Accelerate

/**
    Treshholds the color at the half point (128)
     - Parameters:
      - pixelColor: single channel of the pixel to be quantitized
     - Returns: The Thresholded color
 */
internal func quantitizeGrayScale(pixelColor: UInt8) -> UInt8{
    return pixelColor < 128 ? 0 : 255
}

/**
    Applies the quantization to the RGB buffer
    - Parameters:
     - imageData: the Image buffer in reference formart(Prefix &) and **must** be in RGB format
     - quantization: [color Tuple](x-source-tag://colorTuple) to multiply
     - x: X axis (Column) position to be modified
     - y: Y axis (Row) position to be modified
     - width: total width of the buffer
     - bytesPerPixel: offset of the number of channels
     - errorBias: the bias used to spread the quantization value
  */
internal func applyQuantization(_ imageData: inout UnsafeMutablePointer<UInt8>,_ quantization: colorTuple, x: Int, y: Int, width: Int, bytesPerPixel: Int, errorBias: Double = 7/16){
    let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)

    let r = Int(round(Double(imageData[index]) + Double(quantization.r) * errorBias))
    let g = Int(round(Double(imageData[index + 1]) + Double(quantization.g) * errorBias))
    let b = Int(round(Double(imageData[index + 2]) + Double(quantization.b) * errorBias))

    assignNewColorsTo(imageData: &imageData, index: index, colors: (r, g, b))
    
}

/**
 Takes the previoulsy grayScaled image and threshHolds each pixel
    - Parameters:
     - grayScaleImage: previously converted CGImage
    - Returns: Tuple of CGContext, ImageData and Bytes per pixel
 */
internal func prepareQuantization(grayScaleImage cgImage: CGImage) throws -> (CGContext,UnsafeMutablePointer<UInt8>, Int) {
    let width = cgImage.width
    let height = cgImage.height
    
    let (imageContext, grayImageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage, width: cgImage.width, height: cgImage.height)
    
    for y in 0..<height{
        for x in 0..<width{
            let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
            
            let newColor = quantitizeGrayScale(pixelColor: grayImageData[index])
            
            grayImageData[index] = newColor
            
        }
    }
    
    return (imageContext,grayImageData, bytesPerPixel)
}
