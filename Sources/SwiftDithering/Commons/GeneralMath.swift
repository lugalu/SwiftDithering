//
//  File.swift
//  
//
//  Created by Lugalu on 18/07/23.
//

import Foundation

func indexCalculator(x: Int, y: Int, width: Int, bytesPerPixel: Int) -> Int{
    return (y * width + x) * bytesPerPixel
}

func getRgbFor( index: Int, inData data: UnsafeMutablePointer<UInt8>) -> (r: UInt8, g: UInt8, b: UInt8){
    let r = data[index]
    let g = data[index + 1]
    let b = data[index + 2]
    
    return (r, g, b)
}

func assingNewColorsTo(imageData: inout UnsafeMutablePointer<UInt8>, index: Int, colors: (r:Int,g:Int,b:Int)){
    imageData[index] = UInt8(clamping: colors.r)
    imageData[index + 1] = UInt8(clamping: colors.g)
    imageData[index + 2] = UInt8(clamping: colors.b)
}


