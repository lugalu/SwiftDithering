//
//  File.swift
//  
//
//  Created by Lugalu on 30/07/23.
//

import Accelerate
import UIKit

func convertColorSpaceToGrayScale(_ cgImage: CGImage) throws -> CGImage{
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
    
    return result
}

func convertColorSpaceToRGB(_ cgImage: CGImage) throws -> CGImage{
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
    
    return result

}

