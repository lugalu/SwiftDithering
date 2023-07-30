//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import UIKit

/// Original Color is a tuple containing the three main channels (RGB) in UInt8 format, respecting the 0-255 color range.
/// - Tag: colorTuple
typealias colorTuple = (r: Int, g: Int, b: Int)

/// Original Color is a tuple containing the three main channels (RGB) in UInt8 format, respecting the 0-255 color range.
/// - Tag: originalColor
typealias originalColor = (r: UInt8, g: UInt8, b: UInt8)

/**
 Calculates the Index for given XY coord with Width and Bytes being the offset. The calculation is (x * width + x ) * bytesPerPixel
 - Parameters:
  - x: Pixel position in the X axis (Column)
  - y: Pixel position in the Y axis (Row)
  - width: Total width of the image
  - bytesPerPixel: Total amount of bytes for each Pixel in a sRGB this is 4 bytes
 - Returns: The Index
 */
internal func indexCalculator(x: Int, y: Int, width: Int, bytesPerPixel: Int) -> Int{
    return (y * width + x) * bytesPerPixel
}

/**
 Returns the value clamped to the space defined.
 * min: 1, value: 2, max: 5 returns 2;
 * min: 1, value: 7, max: 5 returns 5;
- Parameters:
   - min: Minimal value possible for the value;
   - value: Value to be clamped;
   - max: Maximum value possible for the value;
 - Returns: The value clamped to the specified range.
 */
public func clamp<T: Comparable & Numeric>(min minValue:T, value:T, max maxValue:T) -> T {
    return min(maxValue, max(minValue,value))
}

/**
 This function is a helper to retrieve the RGB color for given index for data
 - Parameters:
    - index: The base index of the pixel position, where index 0, +1, +2 represents respectively R,G,B channels of the image.
    - data: The pointer to the UInt8 image buffer it **must** be in sRGB format
 - Returns: A tuple in the format of : [(r: UInt8, g: UInt8, b: UInt8)](x-source-tag://originalColor)
 - Tag: getRgbFor
 */
internal func getRgbFor( index: Int, inData data: UnsafeMutablePointer<UInt8>) -> originalColor {
    let r = data[index]
    let g = data[index + 1]
    let b = data[index + 2]
    
    return (r, g, b)
}

/**
 This function is a helper to substitute the pixel color for given index position for the image buffer
 - Parameters:
  - imageData; The UInt8 pointer this **must** be in sRGB format, must be in reference format(adding the prefix & to the variable)
  - index: the base index, as in [getRgbFor](x-source-tag://getRgbFor) will be added to represent all channels
  - colors; the new Colors to be assinged, they are clamped to 0-255 range when applied to prevent crashes
 */
internal func assignNewColorsTo(imageData: inout UnsafeMutablePointer<UInt8>, index: Int, colors: colorTuple) {
    imageData[index] = UInt8(clamping: colors.r)
    imageData[index + 1] = UInt8(clamping: colors.g)
    imageData[index + 2] = UInt8(clamping: colors.b)
}

/**
 Calculates the nearest reduced color pallete based on the factor
 - Parameters:
  - oldColor: [original Color](x-source-tag://originalColor) format containing all 3 RGB channels
  - nearestFactor: The factor for the reduced pallete this is clamped from 0-255 range.
 - Returns:[color Tuple](x-source-tag://colorTuple) for all 3 channels
 */
internal func findClosestPallete(_ oldColor: originalColor, nearestFactor: Int) -> colorTuple{
    let nearestFactor = UInt8(clamping: nearestFactor)
    
    let r =  Int(round(Double(oldColor.r) * Double(nearestFactor))) / Int(nearestFactor)
    let g =  Int(round(Double(oldColor.g) * Double(nearestFactor))) / Int(nearestFactor)
    let b =  Int(round(Double(oldColor.b) * Double(nearestFactor))) / Int(nearestFactor)
    
    return (r,g,b)
}


