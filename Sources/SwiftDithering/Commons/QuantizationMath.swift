//  Created by Lugalu on 30/07/23.

import Foundation
import Accelerate

/**
    Treshholds the color at the half point (128)
     - Parameters:
       - pixelColor: single channel of the pixel to be quantitized
     - Returns: The Thresholded color
 */
internal func quantitizeGrayScale(pixelColor: UInt8, isInverted: Bool = false, thresholdPoint: UInt8 = 128) -> UInt8{
    if isInverted{
        return 255 - Int(pixelColor) < thresholdPoint ? 0 : 255
    }
    
    return pixelColor < thresholdPoint ? 0 : 255
}

internal func randomQuantization(pixelColor: UInt8, isInverted: Bool = false) -> UInt8{
    var pixelColor = pixelColor
    let thresholdPoint = 255 - UInt8.random(in: 0...255)
    
    if isInverted{
        pixelColor = UInt8(clamping:  255 - Int(pixelColor))
    }
    
    return pixelColor < thresholdPoint ? 0 : 255
}

/**
    Applies the quantization to the RGB buffer
    - Parameters:
      - imageData: the Image buffer in reference formart(Prefix &) and **must** be in RGB format
      - quantization: [color Tuple](x-source-tag://colorTuple) to multiply
      - x: X axis (Column) position to be modified
      - y: Y axis (Row) position to be modified
      - width: total width of the buffer
      - bytesPerPixel: offset of the number of channels
      - errorBias: the bias used to spread the quantization value
  */
internal func applyQuantization(_ imageData: inout UnsafeMutablePointer<UInt8>,_ quantization: colorTuple, x: Int, y: Int, width: Int, bytesPerPixel: Int, errorBias: Double = 7/16){
    let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)

    let r = Int(round(Double(imageData[index]) + Double(quantization.r) * errorBias))
    let g = Int(round(Double(imageData[index + 1]) + Double(quantization.g) * errorBias))
    let b = Int(round(Double(imageData[index + 2]) + Double(quantization.b) * errorBias))

    assignNewColorsTo(imageData: &imageData, index: index, colors: (r, g, b))
    
}

/**
 Takes the previoulsy grayScaled image and threshHolds each pixel
  - Parameters:
     - grayScaleImage: previously converted CGImage
  - Returns: Tuple of CGContext, ImageData and Bytes per pixel
 */
internal func prepareQuantization(grayScaleImage cgImage: CGImage) throws -> (CGContext,UnsafeMutablePointer<UInt8>, Int) {
    let width = cgImage.width
    let height = cgImage.height
    
    let (imageContext, grayImageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage, width: cgImage.width, height: cgImage.height)
    
    for y in 0..<height{
        for x in 0..<width{
            let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
            
            let newColor = quantitizeGrayScale(pixelColor: grayImageData[index])
            
            grayImageData[index] = newColor
            
        }
    }
    
    return (imageContext,grayImageData, bytesPerPixel)
}


/**
 Takes the image Data in RGB format and calculates the quantization of given index, thanks to this function it generates a color banding in the image.
    - Parameters:
      - imageData: the image buffer to be quantitized
      - index: base index of the rgb position
      - numberOfBits: number of bits to be used in the quantization
 - Returns: A tuple of UInt8 with the RGB channels quantitized
 */
internal func quantitizeRGB(imageData: UnsafeMutablePointer<UInt8>,index: Int, numberOfBits: Int =  2) -> originalColor{
    
    let tuple = (r: imageData[index], g: imageData[index + 1], b: imageData[index + 2])
    
    return quantitizeRGB(color: tuple, numberOfBits: numberOfBits)
}


/**
 Takes the image Data in RGB format and calculates the quantization of given index, thanks to this function it generates a color banding in the image.
    - Parameters:
      - color: color to quantitize
      - numberOfBits: number of bits to be used in the quantization, by default the value is 2 making the number of bits be 4 is agressive but not the most aggressive(that would be 1)
 - Returns: A tuple of UInt8 with the RGB channels quantitized
 - Tag: quantitizeRGB
 */
func quantitizeRGB(color: originalColor, numberOfBits: Int = 2) -> originalColor{
    var numberOfBits = numberOfBits
    /*
     math behind
     the levels is a left shift of the bits making it jump and deciding the total amount of colors present,
     nowdays the default number of bits for most images seens to be 16 bits so offsetting to 8,4,2 we can get a really nice color banding going on.
     
     we get the buffer value and convert it to 0-1 rgb space then we multiply by the number of bits, rounding to the nearest Int value
     then we normalize the value then we scale back to 0-255 range.
    */
    if numberOfBits <= 0 {
        numberOfBits = 1
    }
    let levels: Double = Double(1 << numberOfBits) - 1
    
    let r = UInt8(clamping: Int(round(Double(color.r) / 255.0 * levels) / levels * 255.0))
    let g = UInt8(clamping: Int(round(Double(color.g) / 255.0 * levels) / levels * 255.0))
    let b = UInt8(clamping: Int(round(Double(color.b) / 255.0 * levels) / levels * 255.0))
    
    return (r,g,b)
}

/**
 Calculates the quantization error based on the two inputs
  - Parameters:
    - originalColor: The original Color of the buffer, this is what is subtracted
    - quantitizedColor: The quantitized color calculated from the chosen quantization method
    - isInverted: When this is on the QuantitizedColor becomes the subtracted, while not accurate to the original dithering, it can lead to interesting visual results in some images
 - Returns: a new Color tuple with the quantitized Value
 */
func makeQuantizationError(originalColor: originalColor, quantitizedColor: originalColor, isInverted: Bool = false) -> colorTuple {
    
    let originalColor = convertOriginalColor(originalColor)
    let quantitizedColor = convertOriginalColor(quantitizedColor)
    return makeQuantizationError(originalColor: originalColor, quantitizedColor: quantitizedColor)
}

/**
 Calculates the quantization error based on the two inputs
  - Parameters:
    - originalColor: The original Color of the buffer, this is what is subtracted
    - quantitizedColor: The quantitized color calculated from the chosen quantization method
    - isInverted: When this is on the QuantitizedColor becomes the subtracted, while not accurate to the original dithering, it can lead to interesting visual results in some images
 - Returns: a new Color tuple with the quantitized Value
 */
func makeQuantizationError(originalColor: colorTuple, quantitizedColor: originalColor, isInverted: Bool = false) -> colorTuple {
    
    let quantitizedColor = convertOriginalColor(quantitizedColor)
    
    return makeQuantizationError(originalColor: originalColor, quantitizedColor: quantitizedColor)
}

/**
 Calculates the quantization error based on the two inputs
  - Parameters:
    - originalColor: The original Color of the buffer, this is what is subtracted
    - quantitizedColor: The quantitized color calculated from the chosen quantization method
    - isInverted: When this is on the QuantitizedColor becomes the subtracted, while not accurate to the original dithering, it can lead to interesting visual results in some images
 - Returns: a new Color tuple with the quantitized Value
 */
func makeQuantizationError(originalColor: originalColor, quantitizedColor: colorTuple, isInverted: Bool = false) -> colorTuple {
    
    let originalColor = convertOriginalColor(originalColor)
    
    return makeQuantizationError(originalColor: originalColor, quantitizedColor: quantitizedColor)
}


/**
 Calculates the quantization error based on the two inputs
  - Parameters:
    - originalColor: The original Color of the buffer, this is what is subtracted
    - quantitizedColor: The quantitized color calculated from the chosen quantization method
    - isInverted: When this is on the QuantitizedColor becomes the subtracted, while not accurate to the original dithering, it can lead to interesting visual results in some images
 - Returns: a new Color tuple with the quantitized Value
 - Tag: makeQuantizationError
 */
func makeQuantizationError(originalColor: colorTuple, quantitizedColor: colorTuple, isInverted: Bool = false) -> colorTuple {
    var error: colorTuple
    if isInverted{
        error = (
            r: quantitizedColor.r - originalColor.r,
            g: quantitizedColor.g - originalColor.g,
            b: quantitizedColor.b - originalColor.b
        )
    }else{
        error = (
            r: originalColor.r - quantitizedColor.r,
            g: originalColor.g - quantitizedColor.g,
            b: originalColor.b - quantitizedColor.b
        )
    }
    
    return error
}
