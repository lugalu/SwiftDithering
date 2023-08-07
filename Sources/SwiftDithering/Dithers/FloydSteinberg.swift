//  Created by Lugalu on 30/07/23.

import UIKit

/**
    Loops through all the pixels on screen then calculate and applies the color for multiple pixels, all is done directly to the image Buffer and all parameters are carried over from [apply Error dither](x-source-tag://applyErrorDifusion) when the type is set to Floyd-Steinberg.
    - Parameters:
      - imageData: the data from the Buffer that will be rendered
      - width: the image Width used to get pixels in X axis (Columns)
      - height: The image height used to get pixels in Y Axis (Rows)
      - bytesPerPixel: Bytes per pixel from finalImageData
      - nearestFactor: Factor for color reduction means the number of allowed bits.
      - numberOfBits: Number of Bits used during the [quantization](x-source-tag://quantitizeRGB) , they suffer a left shift to keep in binary space
      - isQuantizationInverted:Inverts the [quantization Error](x-source-tag://makeQuantizationError) calculation, can lead to interesting results in exchange for innacuracy
 */
internal func floydDither(imageData: inout UnsafeMutablePointer<UInt8>, width: Int, height: Int, bytesPerPixel: Int, nearestFactor: Int, numberOfBits: Int, isQuantizationInverted: Bool) {
    let floydDivider = 16.0
    
    for y in 0..<height {
        for x in 0..<width {
            
            let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
            let quantitizedValue = quantitizeRGB(imageData: imageData, index: index, numberOfBits: 2)
            let oldColor = getRgbFor(index: index, inData: imageData)
            let newColor = findClosestPallete(oldColor, nearestFactor: nearestFactor)
            
            let error = makeQuantizationError(originalColor: newColor, quantitizedColor: quantitizedValue, isInverted: isQuantizationInverted)
            
            assignNewColorsTo(imageData: &imageData, index: index, colors: newColor)
            
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
    }
    
}
