//Created by Lugalu on 31/07/23.

import Foundation

/**
    Logic behind the stucki ditherer assings all the colors as it's called by a looper, this is chosen when .stucki or .fastStucki are called in [apply Error dither](x-source-tag://applyErrorDifusion).
    - Parameters:
      - imageData: the data from the Buffer that will be rendered
      - pos: x, y position to be modified
      - size: width and height of the image
      - quantitizedValue: value to be assigned to current index
      - quantizationError: error to be applied to neighbours pixels
      - bytesPerPixel: Bytes per pixel for the indexCalculation
 */
internal func assignStuckiResults(imageData: inout UnsafeMutablePointer<UInt8>,
                        pos: (x: Int, y: Int),
                        size: (width: Int, height: Int),
                        quantitizedValue: colorTuple,
                        quantizationError error: colorTuple,
                        bytesPerPixel: Int
){
    let stuckiDivider = 42.0
    let index = indexCalculator(x: pos.x, y: pos.y, width: size.width, bytesPerPixel: bytesPerPixel)
    let (x,y) = pos
    let (width, height) = size
    
    assignNewColorsTo(imageData: &imageData, index: index, colors: quantitizedValue)
    
    if x + 1 < width{
        applyQuantization(&imageData, error, x: x + 1, y: y, width: width, bytesPerPixel: bytesPerPixel, errorBias: 8/stuckiDivider)
    }
    
    if x + 2 < width{
        applyQuantization(&imageData, error, x: x + 2, y: y, width: width, bytesPerPixel: bytesPerPixel, errorBias: 4/stuckiDivider)
    }
    
    if y + 1 < height{
        let rowValues: [Double] = [2.0, 4, 8, 4, 2].map{ $0 / stuckiDivider }
        
        applyStuckiToRow(&imageData, error: error, baseX: x, row: y + 1, width: width, bytesPerPixel: bytesPerPixel, biasOrder: rowValues)
    }
    
    if y + 2 < height{
        let rowValues: [Double] = [1.0, 2, 4, 2, 1].map{ $0 / stuckiDivider }
        
        applyStuckiToRow(&imageData, error: error, baseX: x, row: y + 2, width: width, bytesPerPixel: bytesPerPixel, biasOrder: rowValues)
    }
    
}

/**
 Applies the quantization to given row with the given error Bias( x / 42 ), only checks the X to see if is within bounds y must be calculated before calling it
  - Parameters:
     - imageData: buffer to be modified
     - error: the colorTuple with the quantitized error value for each channel
     - baseX: the midlle collumn of the row , this will be subtracted 2 and increased by 2.
     - row: the Y value
     - width: total width of each row to check if X + n is withing bounds
     - bytesPerPixel: needed to calculate the index for each pixel
     - biasOrder: order of values pre-calculated 0 is x-2 4 is x+2 so a minimum of 5 values are needed, if more are passed they don't do anything.
 */
internal func applyStuckiToRow(_ imageData: inout UnsafeMutablePointer<UInt8>, error: (r: Int, g: Int, b: Int), baseX x: Int, row y: Int, width: Int, bytesPerPixel: Int, biasOrder: [Double]){
    guard biasOrder.count >= 5 else { return }
        
    if x - 2 >= 0 {
        applyQuantization(&imageData, error, x: x - 2, y: y, width: width, bytesPerPixel: bytesPerPixel, errorBias: biasOrder[0])
    }
    
    if x - 1 >= 0 {
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

