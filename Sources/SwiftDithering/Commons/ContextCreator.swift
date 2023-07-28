//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import UIKit
import CoreGraphics
import Accelerate

func createContextAndData(cgImage: CGImage, bytesPerPixel: Int? = nil, width: Int, height: Int) throws -> (imageContext: CGContext, imageData: UnsafeMutablePointer<UInt8>, bytesPerPixel: Int){
  
    let colorSpace = cgImage.colorSpace!
    let bytesPerRow = cgImage.bytesPerRow
    let bytesPerPixel = bytesPerPixel ?? bytesPerRow / width
    let bitsPerComponent = cgImage.bitsPerComponent
    
    
    let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * bytesPerPixel)
    
    guard let imageContext = CGContext(data: imageData,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: bitsPerComponent,
                                 bytesPerRow: bytesPerRow,
                                 space: colorSpace,
                                       bitmapInfo: cgImage.bitmapInfo.rawValue
    )
    else {
        throw ImageErrors.failedToCreateContext(localizedDescription: "Context Creation failed! Please generate an issue in the github repository with the image.")
    }
    imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    return (imageContext, imageData, bytesPerPixel)
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

private func createCGImage(source: vImage_CGImageFormat, destination: vImage_CGImageFormat, image: CGImage) throws -> CGImage {
    
    let converter = try vImageConverter.make(sourceFormat: source, destinationFormat: destination)
    
    let sourceBuffer = try vImage_Buffer(cgImage: image)
    var destinationBuffer = try vImage_Buffer( size: sourceBuffer.size,
                                               bitsPerPixel: destination.bitsPerPixel)
    
    try converter.convert(source: sourceBuffer, destination: &destinationBuffer)
    
    let result = try destinationBuffer.createCGImage(format: destination)
    
    defer{
        sourceBuffer.free()
        destinationBuffer.free()
    }
    
    return result
}
