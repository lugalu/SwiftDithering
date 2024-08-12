//Created by Lugalu on 04/08/23.

import UIKit

class CustomMenuComponent: UIView {
    
    private var selected: Int = 0
    
    let button: UIButton = {
        let btn = UIButton(configuration: .tinted(), primaryAction: nil)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.showsMenuAsPrimaryAction = true
        btn.changesSelectionAsPrimaryAction = true
        return btn
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func configure(withTitle title: String, menuContent: [String]){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.addSubview(button)
        label.text = title
        
        let menuAction = { (action: UIAction) in
            guard let title = (action.sender as? UIButton)?.titleLabel?.text, let idx = menuContent.firstIndex(of: title) else {
                print("ops")
                return
            }
            let val = menuContent.distance(from: 0, to: idx)
            self.selected = val
        }
        
        let menuChildren = menuContent.map({ UIAction(title: $0, handler: menuAction) }) as [UIMenuElement]
        
        button.menu = UIMenu(options: .singleSelection, children: menuChildren)
    
        let constraints = [
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -16),
         
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func retrieveValue() -> Int{
        return selected
    }
}
