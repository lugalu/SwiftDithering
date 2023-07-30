//
//  File.swift
//  
//
//  Created by Lugalu on 30/07/23.
//

import UIKit

/**
    Loops through all the pixels on screen then calculate and applies the color for multiple pixels, all is done via the pointer so no need for returns all parameters are carried over from [apply Error dither](x-source-tag://applyErrorDifusion) when the type is set to Floyd-Steinberg.
 */
internal func floydDither(finalImageData: inout UnsafeMutablePointer<UInt8>, quantitizedImageData: UnsafeMutablePointer<UInt8>, width: Int, height: Int, finalImageBytesPerPixel finalBytesPerPixel: Int, quantitizedBytesPerPixel: Int, nearestFactor: Int) {
    
    for y in 0..<height {
        for x in 0..<width {
            let finalImageIndex = indexCalculator(x: x, y: y, width: width, bytesPerPixel: finalBytesPerPixel)
            let quantitizedIndex = indexCalculator(x: x, y: y, width: width, bytesPerPixel: quantitizedBytesPerPixel)
            
            let quantitizedValue = Int(quantitizedImageData[quantitizedIndex])
            let oldColor = getRgbFor(index: finalImageIndex, inData: finalImageData)
            let newColor = findClosestPallete(oldColor, nearestFactor: nearestFactor)
            
            let error = (
                r: quantitizedValue - newColor.r,
                g: quantitizedValue - newColor.g,
                b: quantitizedValue - newColor.b
            )
            
            assignNewColorsTo(imageData: &finalImageData, index: finalImageIndex, colors: newColor)
            
            if x + 1 < width {
                applyQuantization(&finalImageData, error, x: x + 1, y: y, width: width, bytesPerPixel: finalBytesPerPixel)
            }
            if y + 1 < height {
                if x - 1 >= 0 {
                    applyQuantization(&finalImageData, error, x: x - 1, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, multiplier: 3)
                }
                applyQuantization(&finalImageData, error, x: x, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, multiplier: 5)
                
                if x + 1 < width {
                    applyQuantization(&finalImageData, error, x: x + 1, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, multiplier: 1)
                }
            }
            
        }
    }
    
}
