//Created by Lugalu on 22/08/23.

import XCTest
@testable import SwiftDithering

final class QuantizationTestCases: XCTestCase {

    func testQuantitizeGrayScale(){
        let firstTestValue:UInt8 = 255
        let secondTestValue:UInt8 = 127
        let secondTestMidPoint: UInt8 = 120
        
        let firstResult = quantitizeGrayScale(pixelColor: firstTestValue)
        XCTAssertEqual(firstResult, 255)
        
        let secondResult = quantitizeGrayScale(pixelColor: firstTestValue,isInverted: true)
        XCTAssertEqual(secondResult, 0)
        
        let thirdResult = quantitizeGrayScale(pixelColor: secondTestValue)
        XCTAssertEqual(thirdResult, 0)
        
        let fourthResult = quantitizeGrayScale(pixelColor: secondTestValue,isInverted: true)
        XCTAssertEqual(fourthResult, 255)
        
        let fifthResult = quantitizeGrayScale(pixelColor: secondTestValue, thresholdPoint: secondTestMidPoint)
        XCTAssertEqual(fifthResult, 255)
        
        let sixthResult = quantitizeGrayScale(pixelColor: secondTestValue, isInverted: true, thresholdPoint: secondTestMidPoint)
        XCTAssertEqual(sixthResult, 255)
        
    }
    
    
    func testRandomQuantization(){
        XCTAssertNotNil(randomQuantization(pixelColor: 255))
    }
    
    func testApplyQuantization(){
        let x = 0
        let y = 0
        let width = 0
        let bytesPerPixel = 8 * 4
        
        var pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 3)
        pointer[0] = 255
        pointer[1] = 0
        pointer[2] = 128

        let color = (
            255,
            0,
            128
        )
        //Expected 255, 0, 184
        applyQuantization(&pointer, color, x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
        
        XCTAssertEqual(pointer[0], 255)
        XCTAssertEqual(pointer[1], 0)
        XCTAssertEqual(pointer[2], 184)
        pointer.deallocate()
    }
    
    func testQuantitizeRGB(){
        let colors: (r: UInt8, g: UInt8, b: UInt8) = (
            128,
            128,
            128
        )
        
        let result = quantitizeRGB(color: colors,numberOfBits: 2)
        
        XCTAssertEqual(result.r, 170)
        XCTAssertEqual(result.g, 170)
        XCTAssertEqual(result.b, 170)
        
    }

    
    func testMakeQuantizationError(){
        let baseColors = (
            255,
            0,
            128
        )
        
        let error = (
            255,
            128,
            100
        )
        
        let expectedResult = (r:0, g:-128, b:28)
        let expectedInvertedResult = (r:0,g:128,b:-28)
        
        let result = makeQuantizationError(originalColor: baseColors, quantitizedColor: error)
        let invertedResult = makeQuantizationError(originalColor: baseColors, quantitizedColor: error, isInverted: true)
        
        
        XCTAssertEqual(result.r, expectedResult.r)
        XCTAssertEqual(result.g, expectedResult.g)
        XCTAssertEqual(result.b, expectedResult.b)
        
        XCTAssertEqual(invertedResult.r, expectedInvertedResult.r)
        XCTAssertEqual(invertedResult.g, expectedInvertedResult.g)
        XCTAssertEqual(invertedResult.b, expectedInvertedResult.b)
        
    }
    
}
