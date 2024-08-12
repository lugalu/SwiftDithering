//Created by Lugalu on 08/08/24.

import CoreImage

public class OrderedDithering: CIFilter {
    @objc dynamic var inputImage: CIImage?
    /// The matrix to be used, represents 2ˆn
    @objc dynamic var matrixSize: Int = 3
    /// How much to downsample, also represents 2ˆn
    @objc dynamic var downsampleFactor: Int = 2
    @objc dynamic var spread: Float = 0.5
    @objc dynamic var hasColor: Bool = true
    @objc dynamic var numberOfBits: Int = 2
    
    
    public override var outputImage: CIImage? {
        guard var input = inputImage else { return nil }
        let downsampleFactor = clamp(min: 1, value: downsampleFactor, max: 63)
        let callback: CIKernelROICallback = {_,rect in
            return .zero
        }
        
        if !hasColor {
            let filter = CIFilter(name: "CIColorMonochrome")
            filter?.setValue(input, forKey: "inputImage")
            filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
            filter?.setValue(1.0, forKey: "inputIntensity")
                
            guard let out = filter?.outputImage else { return nil }
            input = out
        }
        
        if downsampleFactor > 1 {
            let filter = CIFilter(name: "CILanczosScaleTransform")
            filter?.setValue(input, forKey: "inputImage")
            let scale = 1.0 / Float(1 << downsampleFactor)
            filter?.setValue(scale , forKey: "inputScale")
            guard let out = filter?.outputImage else { return nil }
            input = out
        }
        
        
        let kernel = CIKernel(source: bayerMatrixCalculation + orderedKernel)!
        //sampler s, int factor, float spread, int numberOfBits
        let out = kernel.apply(extent: input.extent, roiCallback: callback, arguments: [
            input,
            matrixSize,
            spread,
            numberOfBits
        ])
        let upscale = CGAffineTransform(scaleX: CGFloat(1 << downsampleFactor), y: CGFloat(1 << downsampleFactor))
        return  out?.transformed(by: upscale)
    }
}

