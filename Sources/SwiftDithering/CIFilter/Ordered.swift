//Created by Lugalu on 08/08/24.

import CoreImage

public class OrderedDithering: CIFilter {
    @objc dynamic var inputImage: CIImage?
    /// The matrix to be used, represents 2ˆn
    @objc dynamic var matrixSize: Int = 1
    /// How much to downsample, also represents 2ˆn
    @objc dynamic var downsampleFactor: Int = 1
    @objc dynamic var spread: Float = 0
    @objc dynamic var hasColor: Bool = true
    @objc dynamic var numberOfBits: Int = 1
    
    private static var bayer8x8: CIImage {
        guard let url = Bundle.module.url(forResource: "bayer8x8", withExtension: "png"),
              let ciBase = CIImage(contentsOf: url) else {
            fatalError("Error loading Bayer 8x8 texture!")
        }
        return ciBase
    }
    
    
    public override var outputImage: CIImage? {
        
        guard var input = inputImage else { return nil }
        var out: CIImage? = input.copy() as! CIImage?
        
        let downsampleFactor = exp2(Double(clamp(min: 1, value: downsampleFactor, max: 63)))
        let callback: CIKernelROICallback = {_,rect in
            return  rect
        }
        
        if !hasColor {
            let filter = CIFilter(name: "CIColorMonochrome")
            filter?.setValue(input, forKey: "inputImage")
            filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
            
            filter?.setValue(1.0, forKey: "inputIntensity")
                
            guard let temp = filter?.outputImage else { return nil }
            out = temp
        }
        
        if downsampleFactor > 1 {
            let filter = CIFilter(name: "CILanczosScaleTransform")
       
           // let scale = 1.0 / downsampleFactor;
            let desiredSize = CGSize(width: input.extent.width / downsampleFactor, height: input.extent.height / downsampleFactor)
            
            let scale = desiredSize.height / input.extent.height
            let aspectRatio = desiredSize.width / (input.extent.width * scale)
            
            filter?.setValue(out, forKey: kCIInputImageKey)
            filter?.setValue(scale , forKey: kCIInputScaleKey)
            filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
            guard let temp = filter?.outputImage else { return nil }
            out = temp
        }
//        
        
        let kernel = CIKernel(source: bayerMatrixCalculation + orderedKernel)!
        //sampler s, int factor, float spread, int numberOfBits
        out = kernel.apply(extent: out!.extent, roiCallback: callback, arguments: [
            out,
            OrderedDithering.bayer8x8,
            matrixSize,
            spread,
            numberOfBits
        ])
        
        if downsampleFactor > 1 {
            let filter = CIFilter(name: "CILanczosScaleTransform")
       
            let desiredSize = CGSize(width: input.extent.width, height: input.extent.height)
            
            let scale = desiredSize.height / out!.extent.height
            let aspectRatio = desiredSize.width / (out!.extent.width * scale)
            
            filter?.setValue(out, forKey: kCIInputImageKey)
            filter?.setValue(scale , forKey: kCIInputScaleKey)
            filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
            guard let temp = filter?.outputImage else { return nil }
            out = temp
        }
        return out
    }
}

