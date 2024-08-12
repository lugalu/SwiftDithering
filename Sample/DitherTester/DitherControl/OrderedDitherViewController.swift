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
        matrixSelector.configure(withTitle: "Bayer Matrix Size", menuContent: ["bayer 2x2", "bayer 4x4", "bayer 8x8"])

        isGPUSelector.configure(withTitle: "Use GPU?")
        isGPUSelector.toggle.setOn(true, animated: true)
        
        isColoredSelector.configure(withTitle: "Image Is Colored")
        isColoredSelector.toggle.setOn(true, animated: true)
        
        inversionSelector.configure(withTitle: "Should Invert")
    
        spreadSlider.configure(withTitle: "Spread", minValue: 0.0, maxValue: 1.0, roundValue: 4.0)
        numberOfBitsSlider.configure(withTitle: "Number Of Bits", minValue: 1, maxValue: 16)
        downscaleSlider.configure(withTitle: "Downscale(2ˆn)", minValue: 0.0, maxValue: 16)
        setupUI()

    }
    
    func retrivedDitheredImage(for image: UIImage?) throws -> UIImage? {
        var ditherType: OrderedDitheringTypes
        let isInverted = inversionSelector.retrieveValue()
        let isColored = !isColoredSelector.retrieveValue()
        let usesGPU = isGPUSelector.retrieveValue()
        let spread = spreadSlider.retrieveValue()
        let numberOfBits = Int(numberOfBitsSlider.retrieveValue())
        let downscaleFactor = Int(downscaleSlider.retrieveValue())
        
        switch (matrixSelector.retrieveValue()){
        case 0:
            ditherType = .bayer(size: .bayer2x2)
        case 1:
            ditherType = .bayer(size: .bayer4x4)
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
            let filter = OrderedDithering()
            let img = image?.ciImage ?? CIImage(image: image ?? UIImage(systemName: "pencil")! )
            
            filter.setValue(img, forKey: "inputImage")
            guard let ciImg = filter.outputImage else { return nil }
            return UIImage(ciImage: ciImg)
        }
        return try image?.applyOrderedDither(withType: ditherType, isInverted: isInverted, isGrayScale: isColored, spread: spread, numberOfBits: numberOfBits, downSampleFactor: downscaleFactor)
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
        
        /*
         case bayer(size: BayerSizes)
         case clusteredDots
         case centralWhitePoint
         case balancedCenteredPoint
         case diagonalOrdered
        */
    }
    
    
}


