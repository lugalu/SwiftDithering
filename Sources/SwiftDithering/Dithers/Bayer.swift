//  Created by Lugalu on 30/07/23.

import Foundation

/**
 This enum contains all the information regarding Bayer matrices from size to matrix values.
 */
public enum BayerSizes: Int{
    case bayer2x2 = 2
    case bayer4x4 = 4
    case bayer8x8 = 8
    
    
    func getBayerMatrix() -> [[UInt8]]{
        switch self{
        case .bayer2x2:
            return [
                [0, 2],
                [3, 1]
            ]
        case .bayer4x4:
            return [
                [0, 8, 2, 10],
                [12, 4, 14, 6],
                [3, 11, 1, 9],
                [15, 7, 13, 5]
            ]
        case .bayer8x8:
            return [
                [ 0, 32,  8, 40,  2, 34, 10, 42],
                [48, 16, 56, 24, 50, 18, 58, 26],
                [12, 44,  4, 36, 14, 46,  6, 38],
                [60, 28, 52, 20, 62, 30, 54, 22],
                [ 3, 35, 11, 43,  1, 33,  9, 41],
                [51, 19, 59, 27, 49, 17, 57, 25],
                [15, 47,  7, 39, 13, 45,  5, 37],
                [63, 31, 55, 23, 61, 29, 53, 21]
            ]
        }
    }
}

/**
   Generic Implementation of Bayer dithering, the base implementation is always the same just the assigner implementation  that determine the final result
    - Parameters:
      - imageData: the buffer to be modified
      - bayerSize: Matrix size and factor to be applied to the image
      - size: Image width and height respectively
      - spread: Amount to deviate from the threshold
      - numberOfBits: if the image is Colored how many colors are allowed
      - bytesPerPixel: total of bytes for the index offset
      - isBayerInverted: if color is gray Scale this inverts the operation making the image darker than normal
      - assigner: executes the pixel modification based on parameters defined in [apply ordered dither](x-source-tag://applyOrderedDither)
 */
internal func genericBayer(_ imageData: inout UnsafeMutablePointer<UInt8>, bayerSize: BayerSizes, size: (width: Int, height: Int), spread: Double = 0.5, numberOfBits:Int, bytesPerPixel: Int, isBayerInverted:Bool, assigner: @escaping (inout UnsafeMutablePointer<UInt8>, Int, UInt8, Bool, Int) -> Void) {
    
#if DEBUG
    let start = CFAbsoluteTimeGetCurrent()
#endif

    
    genericFastImageLooper(imageData: &imageData, width: size.width, height: size.height){ imageData, x, y in
        let index = indexCalculator(x: x, y: y, width: size.width, bytesPerPixel: bytesPerPixel)
        
        let bayerFactor = bayerSize.rawValue
        let bayerMatrixResult = bayerSize.getBayerMatrix()[y % bayerFactor][x % bayerFactor]
        
        // the threshold is multiplied to 1/nˆ2 where n is one of the matrix sizes this together with the subtraction of 1/2 normalizes the value
        // then multiply by 255 to go back to 0-255 range
        
        var bayerValue = Double(bayerMatrixResult)
        bayerValue *= (1 / pow(Double(bayerFactor), 2))
        bayerValue -= 0.5
        bayerValue *= 255
        
        //The deviation of color basic color banding
        let calculatedDeviation = UInt8(clamping: Int(spread * bayerValue))
        
        assigner(&imageData, index, calculatedDeviation, isBayerInverted, numberOfBits)
    }
    
#if DEBUG
    print("Finished bayer dithering totalTime: \(CFAbsoluteTimeGetCurrent() - start)")
#endif
    
}

/**
    Assigns the pixel color when the image is set to grayScale simplest iteration of bayer
    - Parameters:
      - imageData: buffer to be modified
      - index: the pixel to be modified
      - deviation: pre-calculated deviation to be added to the pixel
      - isInverted: if set to On it inverts the average color of the image making it darker if it was white and vice versa
      - numberOfBits: in this assigner it's ignored
 */
internal func assignGrayScaleOrderedDithering(imageData: inout UnsafeMutablePointer<UInt8>, index: Int, deviation: Int, isInverted: Bool, numberOfBits: Int = 0) {
    
    let pixelColor =  UInt8(clamping: Int(imageData[index]) + deviation)
    let quantitizedValue = Int(quantitizeGrayScale(pixelColor: pixelColor, isInverted: isInverted))
   assignNewColorsTo(imageData: &imageData, index: index, colors: quantitizedValue)
}

/**
    Assigns the pixel color when the image is set to RGB
    - Parameters:
      - imageData: buffer to be modified
      - index: the pixel to be modified
      - deviation: pre-calculated deviation to be added to the pixel
      - isInverted: in this assigner it's ignored
      - numberOfBits: the number of colors allowed when calculated we remove -1
 */
internal func assignColoredOrderedDithering(imageData: inout UnsafeMutablePointer<UInt8>,
                               index: Int,
                               deviation: Int,
                               isInverted: Bool,
                               numberOfBits: Int
) {
    let originalPixel = getRgbFor(index: index, inData: imageData)
    
   
    let r = UInt8(clamping: Int(originalPixel.r) + deviation)
    let g = UInt8(clamping: Int(originalPixel.g) + deviation)
    let b = UInt8(clamping: Int(originalPixel.b) + deviation)
    
    let quantitizedValue = quantitizeRGB(color: (r,g,b),numberOfBits: numberOfBits)
    
   assignNewColorsTo(imageData: &imageData, index: index, colors: convertOriginalColor(quantitizedValue))
}
