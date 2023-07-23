//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import UIKit

func createContextAndData(cgImage: CGImage, bytesPerPixel: Int? = nil, width: Int, height: Int) throws -> (imageContext: CGContext, imageData: UnsafeMutablePointer<UInt8>, bytesPerPixel: Int){
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerRow = cgImage.bytesPerRow
    let bytesPerPixel = bytesPerPixel ?? bytesPerRow / width;
    print(bytesPerPixel)
    let bitsPerComponent = cgImage.bitsPerComponent
    
    var imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * bytesPerPixel)
    
    guard let imageContext = CGContext(data: imageData,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: bitsPerComponent,
                                 bytesPerRow: bytesPerRow,
                                 space: colorSpace,
                                 bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
    else {
        throw ImageErrors.failedToCreateContext(localizedDescription: "Context Creation failed! Please generate an issue in the github repository with the image.")
    }
    
    imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    return (imageContext, imageData, bytesPerPixel)
}
