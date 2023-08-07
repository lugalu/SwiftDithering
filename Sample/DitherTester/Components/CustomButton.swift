//Created by Lugalu on 01/08/23.

import UIKit

class CustomButton: UIButton {
    func configure(withTitle title: String, for state: UIControl.State){
        self.configuration?.cornerStyle = .capsule
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: state)
    }
}
