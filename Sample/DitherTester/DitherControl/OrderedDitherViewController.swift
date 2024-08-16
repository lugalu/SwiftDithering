//Created by Lugalu on 03/08/23.

import UIKit
import SwiftDithering

class OrderedDitherViewController: UIViewController, DitherControlProtocol {
    
    let matrixSelector = CustomMenuComponent()
    let isGPUSelector = CustomToggleComponent()
    let isColoredSelector = CustomToggleComponent()
    let inversionSelector = CustomToggleComponent()
    let spreadSlider = CustomSliderComponent()
    let numberOfBitsSlider = CustomSliderComponent()
    let downscaleSlider = CustomSliderComponent()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        matrixSelector.configure(withTitle: "Bayer Matrix Size", menuContent: ["Bayer 2x2", "Bayer 4x4", "Bayer 8x8", "Clustered Dots", "Central White Point", "Balanced White Point", "Diagonal Ordered"])

        isGPUSelector.configure(withTitle: "Use GPU?")
        isGPUSelector.toggle.setOn(true, animated: true)
        
        isColoredSelector.configure(withTitle: "Image Is Colored")
        isColoredSelector.toggle.setOn(true, animated: true)
        
        inversionSelector.configure(withTitle: "Should Invert")
    
        spreadSlider.configure(withTitle: "Spread", minValue: 0.0, maxValue: 1.0, roundValue: 8.0)
        numberOfBitsSlider.configure(withTitle: "Number Of Bits", minValue: 1, maxValue: 16)
        downscaleSlider.configure(withTitle: "Downscale(2ˆn)", minValue: 0.0, maxValue: 16)
        setupUI()

    }
    
    func retrivedDitheredImage(for image: UIImage?) throws -> UIImage? {
        guard let image = image else { return nil }
        let usesGPU = isGPUSelector.retrieveValue()
        var ditherType: OrderedDitheringTypes
        let isInverted = inversionSelector.retrieveValue()
        let isColored = isColoredSelector.retrieveValue()
        let spread = spreadSlider.retrieveValue()
        let numberOfBits = Int(numberOfBitsSlider.retrieveValue())
        let downscaleFactor = Int(downscaleSlider.retrieveValue())
        
        var matrixSize: Int = 3
        
        switch matrixSelector.retrieveValue() {
        case 0:
            ditherType = .bayer(size: .bayer2x2)
            matrixSize = 1
        case 1:
            ditherType = .bayer(size: .bayer4x4)
            matrixSize = 2
        case 2:
            ditherType = .bayer(size: .bayer8x8)
        case 3:
            ditherType = .clusteredDots
        case 4:
            ditherType = .centralWhitePoint
        case 5:
            ditherType = .balancedCenteredPoint
        case 6:
            ditherType = .diagonalOrdered
        default:
            return nil
        }
        
        if usesGPU {
            var inputCIImage: CIImage
            
            if let ci = image.ciImage {
                inputCIImage = ci
            }else {
                guard let cgImg = image.cgImage else { return nil }
                inputCIImage = CIImage(cgImage: cgImg)
            }
            
            let filter = OrderedDithering()
            filter.setValuesForKeys([
                "inputImage": inputCIImage,
                "ditherType": ditherType.getCIFilterID(),
                "matrixSize": matrixSize,
                "downsampleFactor": downscaleFactor,
                "spread": spread,
                "hasColor": isColored,
                "numberOfBits": numberOfBits
            ])
            
            guard let ciImg = filter.outputImage,
                  let cgImage = convertCIImageToCGImage(inputImage: ciImg) else {
                return nil
            }
            
            return UIImage(cgImage: cgImage)
        }
        return try image.applyOrderedDither(withType: ditherType, isInverted: isInverted, isGrayScale: !isColored, spread: spread, numberOfBits: numberOfBits, downSampleFactor: downscaleFactor)
    }


    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
}


extension OrderedDitherViewController{
    func setupUI(){
        addSubviews()
        addPickerConstraints()
        addIsGPUConstraints()
        addIsColoredConstraints()
        addInversionConstraints()
        addSpreadConstraints()
        addNumberOfBitsConstraints()
        addDownscaleConstraints()
    }
    
    func addSubviews(){
        view.addSubview(matrixSelector)
        view.addSubview(isGPUSelector)
        view.addSubview(isColoredSelector)
        view.addSubview(inversionSelector)
        view.addSubview(spreadSlider)
        view.addSubview(numberOfBitsSlider)
        view.addSubview(downscaleSlider)
    }
    

    
    func addPickerConstraints(){
        let constraints = [
            matrixSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            matrixSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -8),
            matrixSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addIsGPUConstraints(){
        let constraints = [
            isGPUSelector.topAnchor.constraint(equalTo: matrixSelector.bottomAnchor,constant: 8),
            isGPUSelector.leadingAnchor.constraint(equalTo: matrixSelector.leadingAnchor),
            isGPUSelector.trailingAnchor.constraint(equalTo: matrixSelector.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addIsColoredConstraints(){
        let constraints = [
            isColoredSelector.topAnchor.constraint(equalTo: isGPUSelector.bottomAnchor,constant: 8),
            isColoredSelector.leadingAnchor.constraint(equalTo: matrixSelector.leadingAnchor),
            isColoredSelector.trailingAnchor.constraint(equalTo: matrixSelector.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addInversionConstraints(){
        let constraints = [
            inversionSelector.topAnchor.constraint(equalTo: isColoredSelector.bottomAnchor, constant: 8),
            inversionSelector.leadingAnchor.constraint(equalTo: matrixSelector.leadingAnchor),
            inversionSelector.trailingAnchor.constraint(equalTo: matrixSelector.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func addSpreadConstraints(){
        let constraints = [
            spreadSlider.topAnchor.constraint(equalTo: inversionSelector.bottomAnchor,constant: 8),
            spreadSlider.leadingAnchor.constraint(equalTo:  matrixSelector.leadingAnchor),
            spreadSlider.trailingAnchor.constraint(equalTo: matrixSelector.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addNumberOfBitsConstraints(){
        let constraints = [
            numberOfBitsSlider.topAnchor.constraint(equalTo: spreadSlider.bottomAnchor,constant: 8),
            numberOfBitsSlider.leadingAnchor.constraint(equalTo:  matrixSelector.leadingAnchor),
            numberOfBitsSlider.trailingAnchor.constraint(equalTo: matrixSelector.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addDownscaleConstraints(){
        let constraints = [
            downscaleSlider.topAnchor.constraint(equalTo: numberOfBitsSlider.bottomAnchor,constant: 8),
            downscaleSlider.leadingAnchor.constraint(equalTo: matrixSelector.leadingAnchor),
            downscaleSlider.trailingAnchor.constraint(equalTo: matrixSelector.trailingAnchor )
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension OrderedDitherViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "2x2"
        case 1:
            return "4x4"
        case 2:
            return "8x8"
        case 3:
            return "Clustered Dots"
        case 4:
            return "Central Point"
        case 5:
            return "Balanced Point"
        case 6:
            return "Diagonal Ordered"
        default:
            return nil
        }
    }
    
    
}


