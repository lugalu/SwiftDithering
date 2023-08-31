//Created by Lugalu on 03/08/23.

import UIKit
import SwiftDithering

class OrderedDitherViewController: UIViewController, DitherControlProtocol {
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.autoresizingMask = .flexibleHeight
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    let matrixSelector = CustomMenuComponent()
    let inversionSelector = CustomToggleComponent()
    let isColoredSelector = CustomToggleComponent()
    let spreadSlider = CustomSliderComponent()
    let numberOfBitsSlider = CustomSliderComponent()
    let downscaleSlider = CustomSliderComponent()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        matrixSelector.configure(withTitle: "Bayer Matrix Size", pickerOwner: self)
        inversionSelector.configure(withTitle: "Should Invert")
        
        isColoredSelector.configure(withTitle: "Image Is Colored")
        isColoredSelector.toggle.setOn(true, animated: true)
    
        spreadSlider.configure(withTitle: "Spread", minValue: 0.0, maxValue: 1.0, roundValue: 4.0)
        numberOfBitsSlider.configure(withTitle: "Number Of Bits", minValue: 1, maxValue: 16)
        downscaleSlider.configure(withTitle: "Downscale(2ˆn)", minValue: 0.0, maxValue: 16)
        setupUI()

    }
    
    func retrivedDitheredImage(for image: UIImage?) throws -> UIImage? {
        var ditherType: OrderedDitheringTypes
        let isInverted = inversionSelector.retrieveValue()
        let isColored = !isColoredSelector.retrieveValue()
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
        
        return try image?.applyOrderedDither(withType: ditherType, isInverted: isInverted, isGrayScale: isColored, spread: spread, numberOfBits: numberOfBits, downSampleFactor: downscaleFactor)
    }
}


extension OrderedDitherViewController{
    func setupUI(){
        addSubviews()
        addScrollViewConstraints()
        addPickerConstraints()
        addInversionConstraints()
        addIsColoredConstraints()
        addSpreadConstraints()
        addNumberOfBitsConstraints()
        addDownscaleConstraints()
    }
    
    func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(matrixSelector)
        scrollView.addSubview(inversionSelector)
        scrollView.addSubview(isColoredSelector)
        scrollView.addSubview(spreadSlider)
        scrollView.addSubview(numberOfBitsSlider)
        scrollView.addSubview(downscaleSlider)
    }
    
    func addScrollViewConstraints(){
        let constraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addPickerConstraints(){
        let constraints = [
            matrixSelector.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            matrixSelector.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,constant: -8),
            matrixSelector.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addInversionConstraints(){
        let constraints = [
            inversionSelector.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            inversionSelector.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,constant: -8),
            inversionSelector.topAnchor.constraint(equalTo: matrixSelector.bottomAnchor,constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addIsColoredConstraints(){
        let constraints = [
            isColoredSelector.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            isColoredSelector.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,constant: -8),
            isColoredSelector.topAnchor.constraint(equalTo: inversionSelector.bottomAnchor,constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addSpreadConstraints(){
        let constraints = [
            spreadSlider.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            spreadSlider.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,constant: -8),
            spreadSlider.topAnchor.constraint(equalTo: isColoredSelector.bottomAnchor,constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addNumberOfBitsConstraints(){
        let constraints = [
            numberOfBitsSlider.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            numberOfBitsSlider.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,constant: -8),
            numberOfBitsSlider.topAnchor.constraint(equalTo: spreadSlider.bottomAnchor,constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addDownscaleConstraints(){
        let constraints = [
            downscaleSlider.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            downscaleSlider.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,constant: -8),
            downscaleSlider.topAnchor.constraint(equalTo: numberOfBitsSlider.bottomAnchor,constant: 8),
            downscaleSlider.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8)
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


