//Created by Lugalu on 08/08/24.

import CoreImage

public class OrderedDithering: CIFilter {
    @objc dynamic var inputImage: CIImage?
    /// The matrix to be used, represents 2ˆn
    @objc dynamic var matrixSize: Int = 1
    /// How much to downsample, also represents 2ˆn
    @objc dynamic var downsampleFactor: Int = 0
    @objc dynamic var spread: Float = 0.125
    @objc dynamic var hasColor: Bool = true
    @objc dynamic var numberOfBits: Int = 2
    
    private static var bayer8x8: CIImage {
        guard let url = Bundle.module.url(forResource: "bayer8x8", withExtension: "png"),
              let ciBase = CIImage(contentsOf: url) else {
            fatalError("Error loading Bayer 8x8 texture!")
        }
        return ciBase
    }
    
    
    public override var outputImage: CIImage? {
        
        guard let input = inputImage else { return nil }
        var out: CIImage? = input.copy() as! CIImage?
        
        let downsampleFactor = Double(clamp(min: 0, value: downsampleFactor, max: 63))
        let callback: CIKernelROICallback = {_,rect in
            return  rect
        }
        
        if !hasColor {
            let filter = CIFilter(name: "CIColorMonochrome")
            filter?.setValue(input.samplingNearest(), forKey: "inputImage")
            filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
            
            filter?.setValue(1.0, forKey: "inputIntensity")
                
            guard let temp = filter?.outputImage else { return nil }
            out = temp
        }
        
        if downsampleFactor > 0 {
            let downsampleFactor = exp2(downsampleFactor)
            let desiredSize = CGSize(width: input.extent.width / downsampleFactor, height: input.extent.height / downsampleFactor)
            let scale = desiredSize.height / input.extent.height
            let transformed = CGAffineTransform(scaleX: scale, y: scale)
            out = out?.samplingNearest().transformed(by: transformed)
        }
//        
        
        let kernel = CIKernel(source: bayerMatrixCalculation + orderedKernel)!
        //sampler s, int factor, float spread, int numberOfBits
        out = kernel.apply(extent: out!.extent, roiCallback: callback, arguments: [
            out!,
            OrderedDithering.bayer8x8.samplingNearest(),
            matrixSize,
            spread,
            numberOfBits
        ])
        
        if downsampleFactor > 0 {
            let desiredSize = CGSize(width: input.extent.width, height: input.extent.height)
            let scale = desiredSize.height / out!.extent.height
            let transformed = CGAffineTransform(scaleX: scale, y: scale)
            out = out?.samplingNearest().transformed(by: transformed)
        }
        return out?.samplingNearest()
    }
}

