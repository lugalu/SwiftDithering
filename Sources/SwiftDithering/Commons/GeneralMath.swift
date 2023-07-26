//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import Foundation
typealias colorTuple = (r: Int, g: Int, b: Int)
typealias originalColor = (r: UInt8, g: UInt8, b: UInt8)

internal func indexCalculator(x: Int, y: Int, width: Int, bytesPerPixel: Int) -> Int{
    return (y * width + x) * bytesPerPixel
}

internal func getRgbFor( index: Int, inData data: UnsafeMutablePointer<UInt8>) -> originalColor{
    let r = data[index]
    let g = data[index + 1]
    let b = data[index + 2]
    
    return (r, g, b)
}

internal func assingNewColorsTo(imageData: inout UnsafeMutablePointer<UInt8>, index: Int, colors: colorTuple){
    imageData[index] = UInt8(clamping: colors.r)
    imageData[index + 1] = UInt8(clamping: colors.g)
    imageData[index + 2] = UInt8(clamping: colors.b)
}

internal func findClosestPallete(_ oldColor: originalColor, isColored: Bool, nearestFactor: Int) -> colorTuple{
//    if !isColored{
//        let r = Int(round(Double(oldColor.r)/255.0))
//        let g = Int(round(Double(oldColor.g)/255.0))
//        let b = Int(round(Double(oldColor.b)/255.0))
//        return (r, g, b)
//    }
    var nearestFactor = UInt8(clamping: nearestFactor)
    
    var r =  Int(round(Double(oldColor.r) * Double(nearestFactor))) / Int(nearestFactor)
    var g =  Int(round(Double(oldColor.g) * Double(nearestFactor))) / Int(nearestFactor)
    var b =  Int(round(Double(oldColor.b) * Double(nearestFactor))) / Int(nearestFactor)
    
    return (r,g,b)
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

internal func applyQuantization(_ imageData: inout UnsafeMutablePointer<UInt8>,_ quantization: colorTuple, x: Int, y: Int, width: Int, bytesPerPixel: Int, outerOverflow: (r: Int?, g: Int?, b: Int?)? = nil, multiplier: Int = 7, divisor: Int = 16) -> (r: Int?, g: Int?, b: Int?) {
    
    let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
    var overflow: (r: Int?, g: Int?, b: Int?) = (nil,nil,nil)
    
    var r = (Int(imageData[index]) + quantization.r * multiplier / divisor) + (outerOverflow?.r ?? 0)
    if r > 255 {
        overflow.r = r - 255
        r = 255
    }
    
    var g = (Int(imageData[index + 1]) + quantization.g * multiplier / divisor) + (outerOverflow?.g ?? 0)
    if g > 255 {
        overflow.g = g - 255
        g = 255
    }
    
    var b = (Int(imageData[index + 2]) + quantization.b * multiplier / divisor) + (outerOverflow?.b ?? 0)
    if b > 255 {
        overflow.b = b - 255
        b = 255
    }
    
    assingNewColorsTo(imageData: &imageData, index: index, colors: (r, g, b))
    
    return overflow
}



