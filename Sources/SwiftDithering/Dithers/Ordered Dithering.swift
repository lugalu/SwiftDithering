//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import UIKit

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

public extension UIImage{
    func applyOrderedDither(withSize bayerSize: BayerSizes, spread: Double = 1.0, bytesPerPixel: Int? = nil) throws -> UIImage{
        guard let cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available") }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = bytesPerPixel ?? bytesPerRow / width;
        let bitsPerComponent = cgImage.bitsPerComponent
        
        var imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * bytesPerPixel)
        defer {
            imageData.deallocate()
        }
        
        guard let imageContext = CGContext(data: imageData,
                                     width: width,
                                     height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: bytesPerRow,
                                     space: colorSpace,
                                     bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )
        else {
            throw ImageErrors.failedToCreateContext(localizedDescription: "Context Creation failed! Please generate an issue in the github repository with the image.")
        }
        
        imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        modifyImageData(&imageData,
                        bayerSize: bayerSize,
                        width: width,
                        height: height,
                        spread: spread,
                        bytesPerPixel: bytesPerPixel)
        
        guard let outputCGImage = imageContext.makeImage()  else {
            throw ImageErrors
            .failedToRetriveCGImage(localizedDescription: "makeimage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
            
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func modifyImageData(_ imageData: inout UnsafeMutablePointer<UInt8>, bayerSize: BayerSizes, width: Int, height: Int, spread: Double, bytesPerPixel: Int){
        for y in 0..<height{
            for x in 0..<width{
                let index = (y * width + x) * bytesPerPixel
                let bayerMatrix = bayerSize.getBayerMatrix()
                let bayerSize = bayerSize.rawValue
                
                let oldR = imageData[index]
                let oldG = imageData[index + 1]
                let oldB = imageData[index + 2]
                
                let bayerValue = Double(bayerMatrix[y % bayerSize][x % bayerSize]) - 0.5
                let newR = Int(Double(oldR) + spread * bayerValue)
                let newG = Int(Double(oldG) + spread * bayerValue)
                let newB = Int(Double(oldB) + spread * bayerValue)
                
                imageData[index] = UInt8(clamping: newR)
                imageData[index + 1] = UInt8(clamping: newG)
                imageData[index + 2] = UInt8(clamping: newB)
                
            }
        }
    }
    
}

