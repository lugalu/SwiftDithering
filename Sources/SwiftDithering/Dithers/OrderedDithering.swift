//  Created by Lugalu on 18/07/23.
#if os(iOS)

import UIKit

public enum OrderedDitheringTypes{
    case bayer(size: BayerSizes)
    case clusteredDots
    case centralWhitePoint
    case balancedCenteredPoint
    case diagonalOrdered
    
    func retriveMatrix() -> [[UInt8]]{
        switch self {
        case .bayer(let size):
            return size.getBayerMatrix()
            
        case .clusteredDots:
            return [
                [34, 29, 17, 21, 30, 35],
                [28, 14, 9, 16, 20, 31],
                [13, 8, 4, 5, 15, 19],
                [12, 3, 0, 1, 10, 18],
                [27, 7, 2, 6, 23, 24],
                [33, 26, 11, 22, 25, 32]
            ]
            
        case .centralWhitePoint:
            return [
                [34, 25, 21, 17, 29, 33],
                [30, 13, 9, 5, 12, 24],
                [18, 6, 1, 0, 8, 20],
                [22, 10, 2, 3, 4, 16],
                [26, 14, 7, 11, 15, 28],
                [35, 31, 19, 23, 27, 32]
            ]
            
        case .balancedCenteredPoint:
            return [
                [30, 22, 16, 21, 33, 35],
                [24, 11, 7, 9, 26, 28],
                [13, 5, 0, 2, 14, 19],
                [15, 3, 1, 4, 12, 18],
                [27, 8, 6, 10, 25, 29],
                [32, 20, 17, 23, 31, 34]
            ]
            
        case .diagonalOrdered:
            let s1: [[UInt8]] = [
                [13, 9, 5, 12],
                [6, 1, 0, 8],
                [10, 2, 3, 4],
                [14, 7, 11, 15]
            ]
            
            let s2: [[UInt8]] = [
                [18, 22, 26, 19],
                [25, 30, 31, 23],
                [21, 29, 28, 27],
                [17, 24, 20, 16]
            ]
            
            var finalMatrix: [[UInt8]] = []
            
            for i in 0..<s1.count{
                finalMatrix.append(s1[i] + s2[i])
            }
            
            for j in 0..<s2.count{
                finalMatrix.append(s2[j] + s1[j])
            }
            
            return finalMatrix
        }
        
    }
    
}

public extension UIImage {
    
    /**
     Applies Ordered Dithering  this dither support colors on the RGB space.
     The image must contain an CGImage to be processed, and this method can cause crashes that Cannot be throw becasue of the draw function.
     - Parameters:
       - bayerSize: The Matrix size used to calculate the color difference;
       - spread: Max distance between the calculated value and the original value by default  equals to 1.0, Warning: the value isn't clamped so going above the threshold can cause artifacts;
       - isGrayScale: if the image should be converted to grayScale only
       - spread: how much deviation should exist when adding the threshold to each pixel recommended to be within 0-1
       - numberOfBits: if the image is colored how many bits per color you allow
       - downSampleFactor: factor(2ˆn) to down sample the image by default is set to 1(halves the image) to not downsample set this to 0.
     - Returns: UIImage with the dithering applied
     - Tag: applyOrderedDither
     */
    func applyOrderedDither(withType type:  OrderedDitheringTypes, isInverted: Bool = false, isGrayScale: Bool = false, spread: Double = 1.0, numberOfBits:Int = 2, downSampleFactor: Int = 1) throws -> UIImage {
        
        guard var cgImage = self.cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available") }
        
        cgImage = try convertColorSpaceToRGB(cgImage)
        cgImage = try downSample(image: cgImage, factor: downSampleFactor)
        var assigner = assignColoredOrderedDithering
        
        if isGrayScale {
            cgImage = try convertColorSpaceToGrayScale(cgImage)
            assigner = assignGrayScaleOrderedDithering
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let matrix = type.retriveMatrix()
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage,
                                                                                width: width,
                                                                                height: height)
        defer {
            imageData.deallocate()
        }
        
        genericOrderedDither(imageData: &imageData,
                             matrix: matrix,
                             imageSize: (width,height),
                             numberOfBits: numberOfBits,
                             bytesPerPixel: bytesPerPixel,
                             spread: spread,
                             isInverted: isInverted,
                             assigner: assigner)
        
        
        guard let outputCGImage = imageContext.makeImage() else {
            throw ImageErrors
                .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
            
        }
        
        return UIImage(cgImage: outputCGImage, scale: 1, orientation: self.imageOrientation)
    }
    
    /**
     Applies Ordered Dithering, more specifically Bayer dithering to the image,  this dither support colors on the RGB space, this is just a convenience function for the normal  applyOrderedDithering
     The image must contain an CGImage to be processed, and this method can cause crashes that Cannot be throw becasue of the draw function.
     - Parameters:
       - bayerSize: The Matrix size used to calculate the color difference;
       - spread: Max distance between the calculated value and the original value by default  equals to 1.0, Warning: the value isn't clamped so going above the threshold can cause artifacts;
       - isGrayScale: if the image should be converted to grayScale only
       - spread: how much deviation should exist when adding the threshold to each pixel recommended to be within 0-1
       - numberOfBits: if the image is colored how much colors you allow
       - downSampleFactor: factor(2ˆn) to down sample the image by default is set to 1(halves the image) to not downsample make this 0.
     - Returns: UIImage with the dithering applied
     
     */
    func applyOrderedDither(withSize bayerSize: BayerSizes, isBayerInverted: Bool = false, isGrayScale: Bool = false, spread: Double = 1.0, numberOfBits:Int = 2, downSampleFactor: Int = 1) throws -> UIImage {
        return try applyOrderedDither(withType: .bayer(size: bayerSize),
                                      isInverted: isBayerInverted,
                                      isGrayScale: isGrayScale,
                                      spread: spread,
                                      numberOfBits: numberOfBits,
                                      downSampleFactor: downSampleFactor)
    }
    
}

//Generic Ordered
func genericOrderedDither(imageData: inout UnsafeMutablePointer<UInt8>,
                          matrix: [[UInt8]],
                          imageSize: (width: Int, height: Int),
                          numberOfBits: Int,
                          bytesPerPixel: Int,
                          spread: Double,
                          isInverted: Bool,
                          assigner: @escaping (inout UnsafeMutablePointer<UInt8>, Int, Int, Bool, Int) -> Void){
    
#if DEBUG
    let start = CFAbsoluteTimeGetCurrent()
#endif
    
    genericFastImageLooper(imageData: &imageData, width: imageSize.width, height: imageSize.height){ imageData, x, y in
        let index = indexCalculator(x: x, y: y, width: imageSize.width, bytesPerPixel: bytesPerPixel)
        
        let matrixFactor = matrix.count
        let matrixValue = matrix[y % matrixFactor][x % matrixFactor]
        
        // the threshold is multiplied to 1/nˆ2 where n is one of the matrix sizes this together with the subtraction of 1/2 normalizes the value
        // then multiply by 255 to go back to 0-255 range
        
        let matrixPow = pow(Double(matrixFactor), 2)
        var threshold = Double(matrixValue)
        threshold *= (1 / matrixPow)
        threshold -= 0.5
        threshold *= 255
        
        //The deviation of color basic color banding
        let calculatedDeviation =  Int(spread * threshold)
        
        assigner(&imageData, index, calculatedDeviation, isInverted, numberOfBits)
    }
    
#if DEBUG
    print("Finished bayer dithering totalTime: \(CFAbsoluteTimeGetCurrent() - start)")
#endif
    
}

#endif

