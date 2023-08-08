//Created by Lugalu on 08/08/23.

import UIKit

class CustomToggleComponent: UIView {
    let label: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    func configure(withTitle title: String){
        label.text = title
        
        self.addSubview(label)
        self.addSubview(toggle)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -16),
            
            toggle.topAnchor.constraint(equalTo: self.topAnchor),
            toggle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            toggle.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func retrieveValue() -> Bool{
        return toggle.isOn
    }

}
