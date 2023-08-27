//Created by Lugalu on 17/08/23.

import UIKit
import Accelerate

/**
 Generates a new downsampled Image based on the input can throw Image errors and vimage_Buffer errors
 - Parameters:
   - image: the image to be downsampled
   - factor: the factor used to calculate the total downsample this is the equivalent to 2ˆn. The value must be within 1...63, if outside of this range the original image is returned
 - Warning: The provided Image **MUST** be in any of the RGB color Spaces. Check [convert Color Space to RGB](x-source-tag://convertColorSpaceToRGB) for a built-in solution.
 - Throws: Throws failed to downsample if the value is too high for the image, Throws failed to convert image and failed to retrieve image, and Throws if image buffer or cgImage creation fails
 - Returns: The downsampled image with the RGB ColorSpace
 */
public func downSample(image: CGImage, factor: Int = 1) throws -> CGImage{
    guard (1...63).contains(factor) else {
        return image
    }
    
    let factor = (1 << factor)
    
    let newWidth = image.width / factor
    let newHeight = image.height / factor
        
    guard newWidth > 0, newHeight > 0 else {
        throw ImageErrors.failedToDownsample(localizedDescription: "2ˆFactor Generates: \(factor) That is Larger than Image Size")
    }
    
    var sourceBuffer = try vImage_Buffer(cgImage: image)
    defer{
        sourceBuffer.free()
    }
    
    var downsampleBuffer = try vImage_Buffer(width: newWidth, height: newHeight, bitsPerPixel: UInt32(clamping: image.bitsPerPixel))
    defer{
        downsampleBuffer.free()
    }

    let error = vImageScale_ARGB8888(&sourceBuffer, &downsampleBuffer, nil, vImage_Flags(kvImagePrintDiagnosticsToConsole))
    
    guard error == kvImageNoError else {
        throw ImageErrors.failedToConvertimage(localizedDescription: "Failed to Downsample image to ARGB8888")
    }
    
    guard let imageFormat: vImage_CGImageFormat = .init(cgImage: image) else {
        throw ImageErrors.failedToRetriveCGImage(localizedDescription: "format is invalid")
    }
    
    let image = try downsampleBuffer.createCGImage(format: imageFormat)
    
    return image
}

