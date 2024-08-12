//Created by Lugalu on 21/08/23.

import UIKit
import SwiftDithering

class ThresholdingViewController: UIViewController, DitherControlProtocol {

    
    
    let thresholdingSelector = CustomMenuComponent()
    let thresholdingPoint = CustomSliderComponent()
    let inversionSelector = CustomToggleComponent()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        thresholdingSelector.configure(withTitle: "thresholding Type", menuContent: ["standart"])
        
        thresholdingPoint.configure(withTitle: "Threshold", minValue: 0, maxValue: 255)
        //thresholdingPoint.slider.value = 128
        
        inversionSelector.configure(withTitle: "Is Inverted")
        
    }
    
    func retrivedDitheredImage(for image: UIImage?) async throws -> UIImage? {
        
        var thresholder: ThresholdTypes
        
        switch thresholdingSelector.retrieveValue(){
        case 0:
            thresholder = .fixed
        case 1:
            thresholder = .random
        case 2:
            thresholder = .uniform
        default:
            return nil
        }
        
        let point = UInt8(clamping: Int(thresholdingPoint.retrieveValue()))
        let shouldInvert = inversionSelector.retrieveValue()
        
        return try image?.applyThreshold(withType: thresholder, thresholdPoint: point, isQuantizationInverted: shouldInvert)
    }
    
}

extension ThresholdingViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "Fixed"
        case 1:
            return "Random"
        case 2:
            return "Uniform"
        default:
            return nil
        }
    }
}

extension ThresholdingViewController {
    
    
    func setupUI(){
        addViews()
        addSelectorConstraints()
        addPointConstraints()
        addInversionConstraints()
    }
    
    func addViews(){
        view.addSubview(thresholdingSelector)
        view.addSubview(thresholdingPoint)
        view.addSubview(inversionSelector)
    }
    
    func addSelectorConstraints(){
        let constraints = [
            thresholdingSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            thresholdingSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            thresholdingSelector.topAnchor.constraint(equalTo: view.topAnchor, constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addPointConstraints(){
        let constraints = [
            thresholdingPoint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            thresholdingPoint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            thresholdingPoint.topAnchor.constraint(equalTo: thresholdingSelector.bottomAnchor, constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addInversionConstraints(){
        let constraints = [
            inversionSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            inversionSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            inversionSelector.topAnchor.constraint(equalTo: thresholdingPoint.bottomAnchor, constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
