//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import UIKit
typealias colorTuple = (r: Int, g: Int, b: Int)
typealias originalColor = (r: UInt8, g: UInt8, b: UInt8)

internal func indexCalculator(x: Int, y: Int, width: Int, bytesPerPixel: Int) -> Int{
    return (y * width + x) * bytesPerPixel
}

func clamp<T: Comparable & Numeric>(min minValue:T, value:T, max maxValue:T) -> T {
    return min(maxValue, max(minValue,value))
}

internal func getRgbFor( index: Int, inData data: UnsafeMutablePointer<UInt8>) -> originalColor{
    let r = data[index]
    let g = data[index + 1]
    let b = data[index + 2]
    
    return (r, g, b)
}

internal func assignNewColorsTo(imageData: inout UnsafeMutablePointer<UInt8>, index: Int, colors: colorTuple){
    imageData[index] = UInt8(clamping: colors.r)
    imageData[index + 1] = UInt8(clamping: colors.g)
    imageData[index + 2] = UInt8(clamping: colors.b)
}

internal func findClosestPallete(_ oldColor: originalColor, nearestFactor: Int) -> colorTuple{
//    if !isColored{
//        let r = Int(round(Double(oldColor.r)/255.0))
//        let g = Int(round(Double(oldColor.g)/255.0))
//        let b = Int(round(Double(oldColor.b)/255.0))
//        return (r, g, b)
//    }
    let nearestFactor = UInt8(clamping: nearestFactor)
    
    let r =  Int(round(Double(oldColor.r) * Double(nearestFactor))) / Int(nearestFactor)
    let g =  Int(round(Double(oldColor.g) * Double(nearestFactor))) / Int(nearestFactor)
    let b =  Int(round(Double(oldColor.b) * Double(nearestFactor))) / Int(nearestFactor)
    
    return (r,g,b)
}

internal func quantitizeGrayScale(pixelColor: UInt8) -> UInt8{
    return pixelColor > 128 ? 255 : 0
}

internal func makeQuantization(_ colorA: colorTuple, colorB: colorTuple) -> colorTuple{
    let newTuple = (r: colorA.r - colorB.r,
                    g: colorA.g - colorB.g,
                    b: colorA.b - colorB.b)
    return newTuple
}

internal func makeQuantization(_ colorA: originalColor, colorB: colorTuple) -> colorTuple{
    let r = Int(colorA.r)
    let g = Int(colorA.g)
    let b = Int(colorA.b)
    
    return makeQuantization((r,g,b), colorB: colorB)
}

internal func applyQuantization(_ imageData: inout UnsafeMutablePointer<UInt8>,_ quantization: colorTuple, x: Int, y: Int, width: Int, bytesPerPixel: Int, multiplier: Int = 7, divisor: Int = 16){
    let errorBias: Double = Double(multiplier) / Double(divisor)
    let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
    
    
    var r = Int(round(Double(imageData[index]) + Double(quantization.r) * errorBias))
    var g = Int(round(Double(imageData[index + 1]) + Double(quantization.g) * errorBias))
    var b = Int(round(Double(imageData[index + 2]) + Double(quantization.b) * errorBias))

    r = clamp(min: 0, value: r, max: 255)
    g = clamp(min: 0, value: g, max: 255)
    b = clamp(min: 0, value: b, max: 255)
    

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
