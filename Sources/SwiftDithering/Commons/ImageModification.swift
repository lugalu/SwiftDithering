//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import Foundation

/**
    Loops through all the pixels on screen then calculate and applies the color, all is done via the pointer so no need for returns all parameters are carried over from [apply ordered dither](x-source-tag://applyOrderedDither)
 */
internal func modifyOrderedImageData(_ imageData: inout UnsafeMutablePointer<UInt8>, bayerSize: BayerSizes, width: Int, height: Int, spread: Double, bytesPerPixel: Int){
    for y in 0..<height{
        for x in 0..<width{
            let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
            
            let bayerFactor = bayerSize.rawValue
            let bayerMatrixResult = bayerSize.getBayerMatrix()[y % bayerFactor][x % bayerFactor]
            let bayerValue = Double(bayerMatrixResult) - 0.5
            
            let (oldR, oldG, oldB) = getRgbFor(index: index, inData: imageData)
            
            let newR = Int(Double(oldR) + spread * bayerValue)
            let newG = Int(Double(oldG) + spread * bayerValue)
            let newB = Int(Double(oldB) + spread * bayerValue)
            
            assingNewColorsTo(imageData: &imageData, index: index, colors: (newR, newG, newB))
            
        }
    }
}

/**
    Loops through all the pixels on screen then calculate and applies the color for multiple pixels, all is done via the pointer so no need for returns all parameters are carried over from [apply Error dither](x-source-tag://applyErrorDifusion) when the type is set to Floyd-Steinberg.
 */
internal func modifyFloydImageData(_ imageData: inout UnsafeMutablePointer<UInt8>, isColored: Bool, width: Int, height: Int, bytesPerPixel: Int, nearestFactor: Int){
    for y in 0..<height{
        for x in 0..<width{
            let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
            var oldPixel = getRgbFor(index: index, inData: imageData)
            var newPixel = findClosestPallete(oldPixel, isColored: isColored,nearestFactor: nearestFactor)
            
            assingNewColorsTo(imageData: &imageData, index: index, colors: newPixel)
            let quantization = makeQuantization(oldPixel, colorB: newPixel)
            
            applyQuantization(&imageData, quantization, x: x + 1, y: y, width: width, bytesPerPixel: bytesPerPixel)
            applyQuantization(&imageData, quantization, x: x - 1, y: y + 1, width: width, bytesPerPixel: bytesPerPixel, multiplier: 3)
            applyQuantization(&imageData, quantization, x: x, y: y + 1, width: width, bytesPerPixel: bytesPerPixel, multiplier: 5)
            applyQuantization(&imageData, quantization, x: x + 1, y: y + 1, width: width, bytesPerPixel: bytesPerPixel, multiplier: 1)
            
        }
    }
}

//TODO: Error Difusion Stucki type
//TODO: others
