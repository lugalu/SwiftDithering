//  Created by Lugalu on 30/07/23.

import UIKit

/**
    Loops through all the pixels on screen then calculate and applies the color for multiple pixels, all is done directly to the image Buffer and all parameters are carried over from [apply Error dither](x-source-tag://applyErrorDifusion) when the type is set to Floyd-Steinberg.
    - Parameters:
      - finalImageData: the data from the Buffer that will be rendered
      - quantitizedImageData: the buffer that was made into gray Scale but **must** retain the RGB format
      - width: the image Width used to get pixels in X axis (Columns)
      - height: The image height used to get pixels in Y Axis (Rows)
      - finalImageBytesPerPixel: Bytes per pixel from finalImageData
      - quantitizedBytesPerPixel: Bytes per pixel from quantitizedImageData
      - nearestFactor: Factor for color reduction means the number of allowed bits.
 */
internal func floydDither(finalImageData: inout UnsafeMutablePointer<UInt8>, quantitizedImageData: UnsafeMutablePointer<UInt8>, width: Int, height: Int, finalImageBytesPerPixel finalBytesPerPixel: Int, quantitizedBytesPerPixel: Int, nearestFactor: Int) {
    let floydDivider = 16.0
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
                    applyQuantization(&finalImageData, error, x: x - 1, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, errorBias: 3 / floydDivider)
                }
                applyQuantization(&finalImageData, error, x: x, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, errorBias: 5 / floydDivider)
                
                if x + 1 < width {
                    applyQuantization(&finalImageData, error, x: x + 1, y: y + 1, width: width, bytesPerPixel: finalBytesPerPixel, errorBias: 1 / floydDivider)
                }
            }
            
        }
    }
    
}
