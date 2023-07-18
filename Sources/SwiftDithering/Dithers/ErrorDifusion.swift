//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import UIKit

public enum ErrorDifusionTypes{
    case floydSteinberg
    case stucki
}

public extension UIImage{
    func applyErrorDifusion(withType diffusionType: ErrorDifusionTypes, isColored: Bool = false, threshold: Int = 1/16) throws{
        guard let cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available")}
        let width = cgImage.width
        let height = cgImage.height
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage, width: width, height: height)
        defer{
            imageData.deallocate()
        }
        
        for y in 0..<height{
            for x in 0..<width{
                let index = (y * width + x) * bytesPerPixel
                var oldPixel = getRgbFor(index: index, inData: imageData)
                
            }
        }
    }
    
    func findClosestPallete(_ oldColor: (r: UInt8, g: UInt8, b: UInt8), isColored: Bool = false) -> (r: UInt8,g: UInt8,b: UInt8){
        if !isColored{
            let r = UInt8(clamping: oldColor.r/255)
            let g = UInt8(clamping: oldColor.g/255)
            let b = UInt8(clamping: oldColor.b/255)
            return (r, g, b)
        }
        //TODO: Implement nearest Neighboor
        
        return (1,1,1)
    }
}
