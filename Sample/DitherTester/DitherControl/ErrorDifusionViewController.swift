//Created by Lugalu on 03/08/23.

import UIKit
import SwiftDithering

class ErrorDifusionViewController: UIViewController, DitherControlProtocol {
    
    let difusionSelector: CustomMenuComponent = CustomMenuComponent()
    let factorSelector: CustomSliderComponent = CustomSliderComponent()
    let fastSelector: CustomToggleComponent = CustomToggleComponent()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func retrivedDitheredImage(for image: UIImage?) throws -> UIImage? {
        var difusionType: ErrorDifusionTypes
        switch difusionSelector.retrieveValue(){
        case 0:
            difusionType = fastSelector.retrieveValue() ? .fastFloydSteinberg : .floydSteinberg
        case 1:
            difusionType = fastSelector.retrieveValue() ? .fastStucki : .stucki
        default:
            difusionType = .floydSteinberg
            
        }
        
        let factor = Int(round(factorSelector.retrieveValue()))

        return try image?.applyErrorDifusion(withType: difusionType, nearestFactor: factor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        difusionSelector.configure(withTitle: "Difusion Type", pickerOwner: self)
        factorSelector.configure(withTitle: "Nearest Factor", minValue: 2.0, maxValue: 16.0)
        fastSelector.configure(withTitle: "Should Multithread")
    }

}

extension ErrorDifusionViewController{
    
    func setupUI(){
        addSubviews()
        addPickerConstraints()
        addSliderConstraint()
        addToggleConstraints()
    }
    
    func addSubviews(){
        view.addSubview(difusionSelector)
        view.addSubview(factorSelector)
        view.addSubview(fastSelector)
    }
    
    func addPickerConstraints(){
        let constraints = [
            difusionSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            difusionSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -8),
            difusionSelector.topAnchor.constraint(equalTo: view.topAnchor,constant: 8),
            difusionSelector.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -15)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addSliderConstraint(){
        let constraints = [
            factorSelector.topAnchor.constraint(equalTo: difusionSelector.bottomAnchor, constant: 8),
            factorSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            factorSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addToggleConstraints(){
        let constraints = [
            fastSelector.topAnchor.constraint(equalTo: factorSelector.bottomAnchor, constant: 8),
            fastSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            fastSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            fastSelector.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}


extension ErrorDifusionViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "Floyd Steinberg"
        case 1:
            return "Stucki"
        default:
            return nil
        }
    }
}



