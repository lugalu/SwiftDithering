//Created by Lugalu on 20/08/23.

import UIKit

public enum ThresholdTypes{
    case fixed
    case random
    case uniform
    
    static func getUniformValue(forColor value: UInt8) -> UInt8{
        var uniformValue: UInt8
        
        switch value{
        case 0...31:
            uniformValue = 16
        case 32...63:
            uniformValue = 48
        case 64...95:
            uniformValue = 80
        case 96...127:
            uniformValue = 112
        case 128...159:
            uniformValue = 144
        case 160...191:
            uniformValue = 176
        case 192...223:
            uniformValue = 208
        default:
            uniformValue = 240
        }
        
        return uniformValue
    }
    
}


public extension UIImage{
    
    func applyThreshold(withType type: ThresholdTypes, thresholdPoint: UInt8 = 128, isQuantizationInverted: Bool = false) throws -> UIImage?{
        guard var cgImage = self.cgImage else { throw ImageErrors.failedToRetriveCGImage(localizedDescription: "needed CGImage is not Available") }
        
        cgImage = try convertColorSpaceToGrayScale(cgImage)

        var assigner: (inout UnsafeMutablePointer<UInt8>, Int, Bool, UInt8) -> Void
        
        switch type{
        case .fixed:
            assigner = assignFixedThreshold
        case .random:
            assigner = assignRandomThreshold
        case .uniform:
            assigner = assignUniformThreshold
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var (imageContext, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage,
                                                                                width: width,
                                                                                height: height)
        
        defer {
            imageData.deallocate()
        }
        
        genericThresholding(&imageData,
                            width: width,
                            height: height,
                            bytesPerPixel: bytesPerPixel,
                            isQuantizationInverted: isQuantizationInverted,
                            thresholdPoint: thresholdPoint,
                            assigner: assigner)
        
        guard let outputCGImage = imageContext.makeImage() else {
            throw ImageErrors
                .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
            
        }
        
        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    
}


func assignFixedThreshold(imageData: inout UnsafeMutablePointer<UInt8>, index: Int, isQuantizationInverted: Bool, thresholdPoint: UInt8){
    let oldColor = imageData[index]
    let quantitizedValue = Int(quantitizeGrayScale(pixelColor: oldColor, isInverted: isQuantizationInverted, thresholdPoint: thresholdPoint))
    
    assignNewColorsTo(imageData: &imageData, index: index, colors: quantitizedValue)
}

func assignRandomThreshold(imageData: inout UnsafeMutablePointer<UInt8>, index: Int, isQuantizationInverted: Bool, thresholdPoint: UInt8){
    let oldColor = imageData[index]
    let quantitizedValue = Int(randomQuantization(pixelColor: oldColor, isInverted: isQuantizationInverted))
    
    assignNewColorsTo(imageData: &imageData, index: index, colors: quantitizedValue)
}

func assignUniformThreshold(imageData: inout UnsafeMutablePointer<UInt8>, index: Int, isQuantizationInverted: Bool, thresholdPoint: UInt8){
    var oldColor = imageData[index]
    
    if isQuantizationInverted {
        oldColor = UInt8(clamping: abs(255 - Int(oldColor)))
    }
    
    let quantitizedValue = Int(ThresholdTypes.getUniformValue(forColor: oldColor))
    
    assignNewColorsTo(imageData: &imageData, index: index, colors: quantitizedValue)

}

func genericThresholding(_ imageData: inout UnsafeMutablePointer<UInt8>,
                         width: Int, height: Int,
                         bytesPerPixel: Int,
                         isQuantizationInverted: Bool,
                         thresholdPoint: UInt8,
                         assigner: @escaping (inout UnsafeMutablePointer<UInt8>, Int,  Bool, UInt8) -> Void) {
    
    genericFastImageLooper(imageData: &imageData, width: width, height: height){ imageData, x, y in
        let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
        
        assigner(&imageData, index, isQuantizationInverted, thresholdPoint)
    }
}


/*
 func uniformQuantization(image: UIImage, numLevels: Int) -> UIImage? {
     guard let inputCGImage = image.cgImage else {
         return nil
     }
     
     let buffer = UnsafeBufferPointer<UInt8>(start: quantizedData.assumingMemoryBound(to: UInt8.self), count: width * height)
     
     let minIntensity = buffer.min() ?? 0
     let maxIntensity = buffer.max() ?? 255
     let intensityRange = Double(maxIntensity - minIntensity)
     let intervalSize = intensityRange / Double(numLevels)
     
     var quantizedImagePixels = [UInt8](repeating: 0, count: width * height)
     
     for i in 0..<buffer.count {
         let originalIntensity = Double(buffer[i])
         let quantizedIntensity = UInt8(round((originalIntensity - Double(minIntensity)) / intervalSize) * intervalSize + Double(minIntensity))
         quantizedImagePixels[i] = quantizedIntensity
     }
     
     let quantizedCGImage = quantizedImagePixels.withUnsafeBytes { ptr in
         return CGDataProvider(data: ptr.baseAddress!.assumingMemoryBound(to: UInt8.self))!
     }
     
     return UIImage(cgImage: quantizedCGImage, scale: image.scale, orientation: image.imageOrientation)
 }
 
 
 */
