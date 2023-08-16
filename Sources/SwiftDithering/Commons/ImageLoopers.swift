//Created by Lugalu on 15/08/23.

import Foundation

/**
 Loops using single threaded operations given width and height, the implementation is based on nested for loops.
 - Parameters:
   - imageData: buffer must be here to conform to swift inout policy, is just send through the loop as an argument of the content
   - width: image width sets the current X axis value
   - height: image width sets the current  Y axis value
   - content: the generic content to be looped, the pointer just refer back to the imageData parameter, X and Y is the current pixel position to make easier to calculate,
 */
internal func genericImageLooper(imageData: inout UnsafeMutablePointer<UInt8>,
                                 width: Int, height: Int,
                                 content: @escaping (_ imgData: inout UnsafeMutablePointer<UInt8>,_ x:Int,_ y:Int) -> Void) {
    for y in 0..<height{
        for x in 0..<width{
            content(&imageData, x, y)
        }
    }
}

/**
 Loops using multithreaded operations given width and height, the implementation is based on nested DispatchQueue.concurrentPerform.
 - Parameters:
   - imageData: buffer must be here to conform to swift inout policy, is just send through the loop as an argument of the content
   - width: image width sets the thread X axis value
   - height: image width sets the thread  Y axis value
   - content: the generic content to be looped, the pointer just refer back to the imageData parameter, X and Y is the current pixel position to make easier to calculate,
 */
internal func genericFastImageLooper(imageData: inout UnsafeMutablePointer<UInt8>,
                                     width: Int, height: Int,
                                     content: @escaping (_ imgData: inout UnsafeMutablePointer<UInt8>,_ x:Int,_ y:Int) -> Void) {
    
    DispatchQueue.concurrentPerform(iterations: height) { y in
        DispatchQueue.concurrentPerform(iterations: width) { x in
            content(&imageData, x, y)
        }
    }
    
    
}
