//
//  File.swift
//  
//
//  Created by Lugalu on 30/07/23.
//

import Foundation
import Accelerate

internal func quantitizeGrayScale(pixelColor: UInt8) -> UInt8{
    return pixelColor < 128 ? 0 : 255
}


internal func applyQuantization(_ imageData: inout UnsafeMutablePointer<UInt8>,_ quantization: colorTuple, x: Int, y: Int, width: Int, bytesPerPixel: Int, multiplier: Int = 7, divisor: Int = 16){
    let errorBias: Double = Double(multiplier) / Double(divisor)
    let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)

    let r = Int(round(Double(imageData[index]) + Double(quantization.r) * errorBias))
    let g = Int(round(Double(imageData[index + 1]) + Double(quantization.g) * errorBias))
    let b = Int(round(Double(imageData[index + 2]) + Double(quantization.b) * errorBias))

    assignNewColorsTo(imageData: &imageData, index: index, colors: (r, g, b))
    
}

func prepareQuantization(grayScaleImage cgImage: CGImage) throws -> (CGContext,UnsafeMutablePointer<UInt8>, Int) {
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
