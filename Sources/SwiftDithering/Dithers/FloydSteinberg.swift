//  Created by Lugalu on 30/07/23.

import UIKit

/**
 Assigner for Floyd-Steingber operations this rules all the Floyg specific math from assigning new colors to applying the specific matrix for this stype of error difusion
 - Parameters:
    - imageData: buffer to be modified
    - pos: x and y current coordinates respectively
    - size: image width and height respectively
    - quantitizedValue: value to be assigned to current pixel
    - quantizationError: error to be spread to neighboring pixels
    - bytesPerPixel: used as the offset of the index, jumping the color channels.
 */
internal func assignFloydResults(imageData: inout UnsafeMutablePointer<UInt8>,
                        pos: (x: Int, y: Int),
                        size: (width: Int, height: Int),
                        quantitizedValue: colorTuple,
                        quantizationError error: colorTuple,
                        bytesPerPixel: Int
){
    let floydDivider = 16.0
    let index = indexCalculator(x: pos.x, y: pos.y, width: size.width, bytesPerPixel: bytesPerPixel)
    let (x,y) = pos
    let (width, height) = size
    
    assignNewColorsTo(imageData: &imageData, index: index, colors: quantitizedValue)
    
    if x + 1 < width {
        applyQuantization(&imageData, error, x: x + 1, y: y, width: width, bytesPerPixel: bytesPerPixel)
    }
    if y + 1 < height {
        if x - 1 >= 0 {
            applyQuantization(&imageData, error, x: x - 1, y: y + 1, width: width, bytesPerPixel: bytesPerPixel, errorBias: 3 / floydDivider)
        }
        applyQuantization(&imageData, error, x: x, y: y + 1, width: width, bytesPerPixel: bytesPerPixel, errorBias: 5 / floydDivider)
        
        if x + 1 < width {
            applyQuantization(&imageData, error, x: x + 1, y: y + 1, width: width, bytesPerPixel: bytesPerPixel, errorBias: 1 / floydDivider)
        }
    }
    
}


