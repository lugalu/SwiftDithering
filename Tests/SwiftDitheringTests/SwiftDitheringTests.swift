import XCTest
@testable import SwiftDithering

final class SwiftDitheringTests: XCTestCase {
    let colorMin = 0
    let colorMax = 255
    
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//        //XCTAssertEqual(SwiftDithering().text, "Hello, World!")
//    }
    
    func testInBoundsClampFunction() {
        let testValue = 10
        
        let result = clamp(min: colorMin, value: colorMax, max: testValue)
        
        XCTAssertEqual(result, testValue)
    }
    
    func testOutOfBoundsClampFunction() {
        let testOverMaxValue = 270
        let testUnderMinValue = -10
        
        let overResult = clamp(min: colorMin, value: testOverMaxValue, max: colorMax)
        let underResult = clamp(min: colorMin, value: testUnderMinValue, max: colorMax)
        
        XCTAssertEqual(overResult, colorMax)
        XCTAssertEqual(underResult, colorMin)
    }
    
    func testIndexCalculator() {
        var y = 0
        var x = 0
        let width = 100
        let bytesPerPixel = 8 * 4
        
        //X = 0 Y = 0 expected 0 (0 * 100 + 0) * 32
        let firstTestCase = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
      
        XCTAssertEqual(firstTestCase, 0)
        
        x = 1
        // X = 1 Y = 0 expected 32 (0 * 100 + 1) * 32
        let secondTestCase = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
        
        XCTAssertEqual(secondTestCase, 32)
        
        
        y = 1
        //X = 1 Y = 1 expected 3232 (1 * 100 + 1) * 32
        let thirdTestCase = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
        
        XCTAssertEqual(thirdTestCase, 3232)
    }
    
    
    
    
}



