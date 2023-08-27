//Created by Lugalu on 22/08/23.

import XCTest
@testable import SwiftDithering

final class DownsamplersTestsCases: XCTestCase {
    var testImage: CGImage = UIImage(systemName: "pencil")!.cgImage!
    
    override func setUpWithError() throws {
        let pencilImage = UIImage(systemName: "pencil")!
        XCTAssertNotNil(pencilImage.cgImage, "If this fails here the test Image is the culprit not the system")
        let cgImage = pencilImage.cgImage!
        testImage = cgImage
    }
    
    
    func testColorConverterRGB() throws{
        testImage = try convertColorSpaceToRGB(testImage)
        
        XCTAssertNotNil(testImage)
    }
    
    func testDownsamplerWithoutDownsampling() throws{
        let newImage = try downSample(image: testImage, factor: 0)
        
        XCTAssertEqual(newImage.width, testImage.width)
        XCTAssertEqual(newImage.height, testImage.height)
    }

    func testDownsamplerHalvingTheImage() throws{
        let newImage = try downSample(image: testImage, factor: 1)
     
        XCTAssertEqual(newImage.width, testImage.width/2)
        XCTAssertEqual(newImage.height, testImage.height/2)
    }
    
    
    func testDownsamplerErrorThrow() throws{
       XCTAssertThrowsError(try downSample(image: testImage, factor: 10))
    }
    
    func testColorConverterGrayScale() throws{
        testImage = try convertColorSpaceToGrayScale(testImage)
        XCTAssertNotNil(testImage)
    }
    
}
//
