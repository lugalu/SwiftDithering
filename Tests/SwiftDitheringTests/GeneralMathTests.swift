import XCTest
@testable import SwiftDithering

final class GeneralMathTests: XCTestCase {
    let colorMin = 0
    let colorMax = 255
    
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
    
    
    func testGetRGB(){
        let index = 0
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 3)
        pointer[0] = 255
        pointer[1] = 0
        pointer[2] = 128
     
        let result = getRgbFor(index: index, inData: pointer)
        
        XCTAssertEqual(result.r, pointer[0])
        XCTAssertEqual(result.g, pointer[1])
        XCTAssertEqual(result.b, pointer[2])
        pointer.deallocate()
    }
    
    func testAssignRGB(){
        let index = 0
        var pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 3)
        
        let colors: (r: Int, g: Int, b: Int) = (
            255,
            0,
            128
        )
        
        assignNewColorsTo(imageData: &pointer, index: index, colors: colors)
        
        XCTAssertEqual(colors.r, Int(pointer[0]))
        XCTAssertEqual(colors.g, Int(pointer[1]))
        XCTAssertEqual(colors.b, Int(pointer[2]))
        pointer.deallocate()
        
    }
    
    func testAssignGray(){
        let index = 0
        var pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        
        let colors: Int = 255
        
        assignNewColorsTo(imageData: &pointer, index: index, colors: colors)
        
        XCTAssertEqual(colors, Int(pointer[0]))
        pointer.deallocate()
    }
    
    func testConvertOriginalColor(){
        let colors: (r: UInt8, g: UInt8, b: UInt8) = (
            255,
            0,
            128
        )
        
        let result = convertOriginalColor(colors)
        
        XCTAssertEqual(result.r, Int(colors.r))
        XCTAssertEqual(result.g, Int(colors.g))
        XCTAssertEqual(result.b, Int(colors.b))
        
    }
    
    func testRecursiveValues(){
        
        func bayerValue(x:Int, y:Int, n: Int) -> Int{
            if n == 1 {
                let res = abs(x * 2 - 3 * y)
                return res
            }
            
            let factor = NSDecimalNumber(decimal: pow(2, n)).intValue
            let x = x % factor
            let y = y % factor
            
            let half = NSDecimalNumber(decimal: pow(2, n-1)).intValue
            let quadrant: Int =  {
                if x < half && y < half {
                    return 0
                }
                
                if x >= half && y < half {
                    return 2
                }
                
                if x < half && y >= half {
                    return 3
                }
                
               return 1
            }()
                        
            let newX = x % half
            let newY = y % half
            
            let res = 4 * bayerValue(x: newX, y: newY, n: n-1) + quadrant
            return res
        }
        
        let n = 3
        let bayer = BayerSizes.bayer8x8
        
        for y in 0...50{
            for x in 0...50 {
                let test = bayerValue(x: x , y: y, n: n)
                XCTAssertEqual(UInt8(clamping:test), bayer.getBayerMatrix()[y%8][x%8])
            }
        }
        
    }
    
}



