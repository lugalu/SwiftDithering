//  Created by Lugalu on 30/07/23.

import UIKit

internal func genericImageLooper(imageData: inout UnsafeMutablePointer<UInt8>,
                                 width: Int, height: Int,
                                 content: @escaping (_ imgData: inout UnsafeMutablePointer<UInt8>,_ x:Int,_ y:Int) -> Void) {
    for y in 0..<height{
        for x in 0..<width{
            content(&imageData, x, y)
        }
    }
}

internal func genericFastImageLooper(imageData: inout UnsafeMutablePointer<UInt8>,
                                     width: Int, height: Int,
                                     content: @escaping (_ imgData: inout UnsafeMutablePointer<UInt8>,_ x:Int,_ y:Int) -> Void) {
    
    DispatchQueue.concurrentPerform(iterations: height) { y in
        DispatchQueue.concurrentPerform(iterations: width) { x in
            content(&imageData, x, y)
        }
    }
    
    
}

internal func genericErrorDifusion(imageData: inout UnsafeMutablePointer<UInt8>,
                                                width: Int,
                                                height: Int,
                                                bytesPerPixel: Int,
                                                numberOfBits: Int,
                                                isQuantizationInverted: Bool,
                                                assigner:  @escaping (inout UnsafeMutablePointer<UInt8>,
                                                                      (Int,Int),
                                                                      (Int,Int),
                                                                      colorTuple,
                                                                      colorTuple,
                                                                      Int) -> Void,
                                            looper: (inout UnsafeMutablePointer<UInt8>,
                                                     Int, Int,
                                                     @escaping (_ imageData: inout UnsafeMutablePointer<UInt8>,
                                                                _ x: Int,
                                                                _ y: Int) -> Void) -> Void) {
         #if DEBUG
             let start = CFAbsoluteTimeGetCurrent()
         #endif
    
    looper(&imageData, width, height){ (imageData,x, y) in

        let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
        let oldColor = getRgbFor(index: index, inData: imageData)
        let quantitizedValue = quantitizeRGB(imageData: imageData, index: index, numberOfBits: numberOfBits)
        let error = makeQuantizationError(originalColor: oldColor, quantitizedColor: quantitizedValue, isInverted: isQuantizationInverted)

        let pos = (x, y)
        let size = (width, height)

        assigner(&imageData, pos, size, convertOriginalColor(quantitizedValue), error, bytesPerPixel)
    }
    
         #if DEBUG
             print("Finished floy dithering totalTime: \(CFAbsoluteTimeGetCurrent() - start)")
         #endif

}


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


