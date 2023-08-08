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
    Loops through all the pixels on screen then calculate and applies the color, all is done via the pointer so no need for returns all parameters are carried over from [apply ordered dither](x-source-tag://applyOrderedDither)
    - Parameters:
     - imageData: the buffer to be modified **must** be in RGB format
     - bayerSize: Matrix size to be applied to the image
     - width: Image width
     - heigt: Image height
     - spread: how far the distorted pixel can be from the original color
     - bytesPerPixel: total of bytes for the index offset
 */
internal func bayerDither(_ imageData: inout UnsafeMutablePointer<UInt8>, bayerSize: BayerSizes, width: Int, height: Int, bytesPerPixel: Int, isBayerInverted: Bool){
    #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
    #endif
   
    DispatchQueue.concurrentPerform(iterations: height){ y in
        for x in 0..<width{
            let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
            
            let bayerFactor = bayerSize.rawValue
            let bayerMatrixResult = bayerSize.getBayerMatrix()[y % bayerFactor][x % bayerFactor]
            let bayerValue = Int(round(Double(bayerMatrixResult) - 0.5))
            
            let quantitizedValue = Int(quantitizeGrayScale(pixelColor: imageData[index]))
            
            var color = 0
            
            if isBayerInverted && quantitizedValue > 1 - bayerValue {
                color = 255
            }else if quantitizedValue > bayerValue{
                color = 255
            }
            
           assignNewColorTo(imageData: &imageData, index: index, colors: color)
        }
    }
    
    #if DEBUG
        print("Finished bayer dithering totalTime: \(CFAbsoluteTimeGetCurrent() - start)")
    #endif
}
