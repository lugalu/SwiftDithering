//Created by Lugalu on 04/08/23.

import UIKit

class CustomMenuComponent: UIView{
    
    let picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func configure(withTitle title: String, pickerOwner: UIPickerViewDelegate & UIPickerViewDataSource){
        label.text = title
        picker.delegate = pickerOwner
        picker.dataSource = pickerOwner
        picker.selectRow(0, inComponent: 0, animated: true)
        
        self.addSubview(label)
        self.addSubview(picker)
        
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -16),
            
            picker.topAnchor.constraint(equalTo: self.topAnchor),
            picker.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            picker.leftAnchor.constraint(equalTo: label.rightAnchor),
            picker.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func retrieveValue() -> Int{
        return picker.selectedRow(inComponent: 0)
    }
}
