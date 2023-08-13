//Created by Lugalu on 03/08/23.

import UIKit
import SwiftDithering

class OrderedDitherViewController: UIViewController, DitherControlProtocol {
    let matrixSelector: CustomMenuComponent = CustomMenuComponent()
    let inversionSelector: CustomToggleComponent = CustomToggleComponent()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        matrixSelector.configure(withTitle: "Bayer Matrix Size", pickerOwner: self)
        inversionSelector.configure(withTitle: "Should Invert")
    }
    
    func retrivedDitheredImage(for image: UIImage?) throws -> UIImage? {
        var bayer: BayerSizes
        let isInverted = inversionSelector.retrieveValue()
        
        switch (matrixSelector.retrieveValue()){
        case 0:
            bayer = .bayer2x2
        case 1:
            bayer = .bayer4x4
        case 2:
            bayer = .bayer8x8
        default:
            return nil
        }

        return try image?.applyOrderedDither(withSize: bayer, isBayerInverted: isInverted)
    }
}


extension OrderedDitherViewController{
    func setupUI(){
        addSubviews()
        addPickerConstraints()
        addInversionConstraints()
    }
    
    func addSubviews(){
        view.addSubview(matrixSelector)
        view.addSubview(inversionSelector)
    }
    
    func addPickerConstraints(){
        let constraints = [
            matrixSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            matrixSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -8),
            matrixSelector.topAnchor.constraint(equalTo: view.topAnchor,constant: 8),
            matrixSelector.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addInversionConstraints(){
        let constraints = [
            inversionSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            inversionSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -8),
            inversionSelector.topAnchor.constraint(equalTo: matrixSelector.bottomAnchor,constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension OrderedDitherViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "2x2"
        case 1:
            return "4x4"
        case 2:
            return "8x8"
        default:
            return nil
        }
    }
    
    
}
