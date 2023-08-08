//Created by Lugalu on 04/08/23.

import UIKit

class CustomSliderComponent: UIView {

    var defaultText = ""
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    
    func configure(withTitle title: String, minValue: Float, maxValue: Float){
        defaultText = title
        slider.maximumValue = maxValue
        slider.minimumValue = minValue
        slider.value = minValue
        label.text = title + " \(retrieveRoundedValue(slider.value))"
        
        slider.addTarget(self, action: #selector(onSlideChange(_:)), for: .valueChanged)
        self.addSubview(label)
        self.addSubview(slider)
        
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -16),
            
            slider.topAnchor.constraint(equalTo: self.topAnchor),
            slider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            slider.leftAnchor.constraint(equalTo: label.rightAnchor,constant: 8),
            slider.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func onSlideChange(_ sender: UISlider){
        label.text = defaultText + " \(retrieveRoundedValue(sender.value))"
    }
    
    func retrieveValue() -> Float{
        return retrieveRoundedValue(slider.value)
    }
    
    private func retrieveRoundedValue(_ value: Float) -> Float{
        return ceil(value * 4) / 4
    }
}
