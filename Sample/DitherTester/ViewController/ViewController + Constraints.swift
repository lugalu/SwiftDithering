//Created by Lugalu on 01/08/23.

import UIKit

extension ViewController{
    func configureUI(){
        addSubViews()
        configureNavBar()
        addImageViewConstraints()
        addDitherSelectorConstraints()
        addApplyConstraints()
        addRevertConstraints()
        addDitherOptionsContraints()

    }
    
    private func addSubViews(){
        view.addSubview(imageView)
        view.addSubview(ditherSelector)
        addChild(ditherOptions)
        view.addSubview(ditherOptions.view)
        view.addSubview(applyButton)
        view.addSubview(revertButton)
    }
    
    private func configureNavBar(){
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "Dither Example"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openGallery))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Default", style: .done, target: self, action: #selector(restoreDefaultImage))
    }
    
    
    private func addImageViewConstraints(){
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: 256)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addDitherSelectorConstraints(){
        let constraints = [
            ditherSelector.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            ditherSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            ditherSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addDitherOptionsContraints(){
        ditherOptions.view.translatesAutoresizingMaskIntoConstraints = false
     
        
        let constraints = [
            ditherOptions.view.topAnchor.constraint(equalTo: ditherSelector.bottomAnchor, constant: 8),
            ditherOptions.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ditherOptions.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ditherOptions.view.bottomAnchor.constraint(equalTo: revertButton.topAnchor, constant: -8)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addRevertConstraints(){
        let constraints = [
            revertButton.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -8),
            revertButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            revertButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            revertButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addApplyConstraints(){
        let constraints = [
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            applyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            applyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            applyButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    

    
}
