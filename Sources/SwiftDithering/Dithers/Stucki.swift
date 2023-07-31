//Created by Lugalu on 31/07/23.

import Foundation

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
internal func stucki(finalImageData: inout UnsafeMutablePointer<UInt8>, quantitizedImageData: UnsafeMutablePointer<UInt8>, width: Int, height: Int, finalImageBytesPerPixel finalBytesPerPixel: Int, quantitizedBytesPerPixel: Int, nearestFactor: Int) {
    
    let stuckiDivider = 42.0
    
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
            
            if x + 1 < width{
                applyQuantization(&finalImageData, error, x: x + 1, y: y, width: width, bytesPerPixel: finalBytesPerPixel, errorBias: 8/42)
            }
            
            if x + 2 < width{
                applyQuantization(&finalImageData, error, x: x + 2, y: y, width: width, bytesPerPixel: finalBytesPerPixel, errorBias: 4/42)
            }
            
            if y + 1 < height{
                let rowValues: [Double] = [2.0, 4, 8, 4, 2].map{ $0 / stuckiDivider }
                
                applyStuckiToRow(&finalImageData, error: error, baseX: x, row: y+1, width: width, bytesPerPixel: finalBytesPerPixel, biasOrder: rowValues)
            }
            
            if y + 2 < height{
                let rowValues: [Double] = [1.0, 2, 4, 2, 1].map{ $0 / stuckiDivider }
                
                applyStuckiToRow(&finalImageData, error: error, baseX: x, row: y + 2, width: width, bytesPerPixel: finalBytesPerPixel, biasOrder: rowValues)
            }
            
        }
    }
    
}

private func applyStuckiToRow(_ imageData: inout UnsafeMutablePointer<UInt8>, error: (r: Int, g: Int, b: Int), baseX x: Int, row y: Int, width: Int, bytesPerPixel: Int, biasOrder: [Double]){
        
        if x - 2 >= width {
            applyQuantization(&imageData, error, x: x - 2, y: y, width: width, bytesPerPixel: bytesPerPixel, errorBias: biasOrder[0])
        }
        
        if x - 1 >= width {
            applyQuantization(&imageData, error, x: x - 1 , y: y, width: width, bytesPerPixel: bytesPerPixel, errorBias: biasOrder[1])
        }
        
        applyQuantization(&imageData, error, x: x , y: y, width: width, bytesPerPixel: bytesPerPixel, errorBias: biasOrder[2])
        
        if x + 1 < width {
            applyQuantization(&imageData, error, x: x + 1 , y: y, width: width, bytesPerPixel: bytesPerPixel, errorBias: biasOrder[3])
        }
        
        if x + 2 < width {
            applyQuantization(&imageData, error, x: x + 2 , y: y, width: width, bytesPerPixel: bytesPerPixel, errorBias: biasOrder[4])
        }
    
}
