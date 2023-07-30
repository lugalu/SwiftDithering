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

internal func createCGImage(source: vImage_CGImageFormat, destination: vImage_CGImageFormat, image: CGImage) throws -> CGImage {
    
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




