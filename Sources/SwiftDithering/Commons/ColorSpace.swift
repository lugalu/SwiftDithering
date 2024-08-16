//  Created by Lugalu on 30/07/23.

import Accelerate
import CoreGraphics

/**
    Converts image to the GrayScale format accepted by Quartz2D containing 16 bits in total (color(0-255) and alpha (0-255))
    - Parameters:
      - cgImage: the image to be converted and re-rendered
    - Returns: the converted image
 - Tag: convertColorSpaceToGrayScale
 */
public func convertColorSpaceToGrayScale(_ cgImage: CGImage) throws -> CGImage{
    #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
    #endif
    guard
        let sourceImageFormat = vImage_CGImageFormat(cgImage: cgImage),
        let grayDestinationBuffer = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 2,
            colorSpace: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)) else {
        throw ImageErrors.failedToConvertimage(localizedDescription: "Unable to initialize")
    }

    let result = try createCGImage(source: sourceImageFormat, destination: grayDestinationBuffer, image: cgImage)
    #if DEBUG
        print("Convert Color Space to Gray total time: \(CFAbsoluteTimeGetCurrent() - start)")
    #endif
    return result
}

/**
    Converts image to the sRGB format accepted by Quartz2D containing 32 bits in total (RGB(0-255) and Alpha (0-255))
    - Parameters:
      - cgImage: the image to be converted and re-rendered
    - Returns: the converted image
 - Tag: convertColorSpaceToRGB
 */
public func convertColorSpaceToRGB(_ cgImage: CGImage) throws -> CGImage{
    #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
    #endif
    guard
        let sourceImageFormat = vImage_CGImageFormat(cgImage: cgImage),
        let rgbDestinationImageFormat = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 4,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)) else {
        throw ImageErrors.failedToConvertimage(localizedDescription: "Unable to initialize")
    }
   
    let result = try createCGImage(source: sourceImageFormat, destination: rgbDestinationImageFormat, image: cgImage)
    
    #if DEBUG
        print("Convert Color Space to RGB total time: \(CFAbsoluteTimeGetCurrent() - start)")
    #endif
    
    return result

}

