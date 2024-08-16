//Created by Lugalu on 08/08/24.

import CoreImage

public extension OrderedDitheringTypes {
    public func getCIFilterID() -> Int {
        switch self {
        case .bayer(_):
            return 1
        case .clusteredDots:
            return 2
        case .centralWhitePoint:
            return 3
        case .balancedCenteredPoint:
            return 4
        case .diagonalOrdered:
            return 5
        }
    }
}

public class OrderedDithering: CIFilter {
    @objc dynamic var inputImage: CIImage?
    //Dither type use the getCIFilterID from OrderedDitheringTypes to select in safe way
    @objc dynamic var ditherType: Int = 1
    /// 1 for matrix 2x2, 2 for 4x4, 3 for any of the other Dither Types
    @objc dynamic var matrixSize: Int = 3
    /// How much to downsample, also represents 2ˆn
    @objc dynamic var downsampleFactor: Int = 0
    @objc dynamic var spread: Float = 0.125
    @objc dynamic var hasColor: Bool = true
    @objc dynamic var numberOfBits: Int = 2
  
    private let callback: CIKernelROICallback = {_,rect in
        return  rect
    }
    
    public override var outputImage: CIImage? {
        
        guard let input = inputImage else { return nil }
        var out: CIImage? = input.copy() as! CIImage?
        let downsampleFactor = Double(clamp(min: 0, value: downsampleFactor, max: 63))

        if !hasColor { out = makeMonochrome(image: out) ?? out }
        
        if downsampleFactor > 0 { out = downsample(image: out, factor: downsampleFactor) }
        
        let (matrix, divider) = getMatrix()
        //sampler s, int factor, float spread, int numberOfBits
        out = OrderedDithering.kernel.apply(extent: out!.extent, roiCallback: callback, arguments: [
            out!,
            matrix,
            Float(divider),
            matrixSize,
            spread,
            numberOfBits
        ])
        
        if downsampleFactor > 0 { out = upsample(image: out, extent: input.extent) ?? out }
        
        return out?.samplingNearest()
    }
}


extension OrderedDithering {
    
    private static var kernel: CIKernel = {
        return CIKernel(source: bayerMatrixCalculation + orderedKernel)!
    }()
    
    private static var bayer8x8: CIImage {
        guard let url = Bundle.module.url(forResource: "bayer8x8", withExtension: "png"),
              let ciBase = CIImage(contentsOf: url) else {
            fatalError("Error loading bayer 8x8 texture!")
        }
        return ciBase
    }
    
    private static var clusteredDots: CIImage {
        guard let url = Bundle.module.url(forResource: "clusteredDots6x6", withExtension: "png"),
              let ciBase = CIImage(contentsOf: url) else {
            fatalError("Error loading clustered 6x6 texture!")
        }
        return ciBase
    }
    
    private static var centralWhitePoint: CIImage {
        guard let url = Bundle.module.url(forResource: "centralWhitePoint6x6", withExtension: "png"),
              let ciBase = CIImage(contentsOf: url) else {
            fatalError("Error loading central 6x6 texture!")
        }
        return ciBase
    }
    
    private static var balancedCenteredPoint: CIImage {
        guard let url = Bundle.module.url(forResource: "balancedCenteredPoint6x6", withExtension: "png"),
              let ciBase = CIImage(contentsOf: url) else {
            fatalError("Error loading balanced 6x6 texture!")
        }
        return ciBase
    }
    
    private static var diagonalOrdered: CIImage {
        guard let url = Bundle.module.url(forResource: "diagonalOrdered8x8", withExtension: "png"),
              let ciBase = CIImage(contentsOf: url) else {
            fatalError("Error loading diagonal 8x8 texture!")
        }
        return ciBase
    }
    
    
    private func makeMonochrome(image: CIImage?) -> CIImage? {
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(image?.samplingNearest(), forKey: "inputImage")
        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        
        filter?.setValue(1.0, forKey: "inputIntensity")
        return filter?.outputImage
    }
    
    private func downsample(image: CIImage?, extent: CGRect? = nil, factor: Double) -> CIImage? {
        guard let extent = extent ?? image?.extent else { return nil }
        let downsampleFactor = exp2(factor)
        let desiredSize = CGSize(width: extent.width / downsampleFactor, height: extent.height / downsampleFactor)
        let scale = desiredSize.height / extent.height
        let transformed = CGAffineTransform(scaleX: scale, y: scale)
        return image?.samplingNearest().transformed(by: transformed)
    }
    
    private func upsample(image: CIImage?, extent: CGRect) -> CIImage?{
        guard let image = image else {return nil}
        let desiredSize = CGSize(width: extent.width, height: extent.height)
        let scale = desiredSize.height / image.extent.height
        let transformed = CGAffineTransform(scaleX: scale, y: scale)
        return image.samplingNearest().transformed(by: transformed)
    }
    
    private func getMatrix() -> (CIImage, Int) {
       return switch ditherType {
        case 1:
           (OrderedDithering.bayer8x8.samplingNearest(), 8)
        case 2:
           (OrderedDithering.clusteredDots.samplingNearest(), 6)
        case 3:
           (OrderedDithering.centralWhitePoint.samplingNearest(), 6)
        case 4:
           (OrderedDithering.balancedCenteredPoint.samplingNearest(), 6)
        case 5:
           (OrderedDithering.diagonalOrdered.samplingNearest() , 8)
       default:
           fatalError("use the OrderedDitheringTypes to safely access this values")
        }
    }
    
}
