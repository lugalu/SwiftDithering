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
            
            assignNewColorsTo(imageData: &imageData, index: index, colors: (newR, newG, newB))
            
        }
    }
}



//TODO: Error Difusion Stucki type
//TODO: others
