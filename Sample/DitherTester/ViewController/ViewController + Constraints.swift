//Created by Lugalu on 01/08/23.

import UIKit

extension ViewController{
    func configureUI(){
        addSubViews()
        configureNavBar()
        addImageViewConstraints()
        addDitherSelectorConstraints()
        addDitherOptionsContraints()
        addApplyConstraints()

    }
    
    private func addSubViews(){
        view.addSubview(imageView)
        view.addSubview(applyButton)
        view.addSubview(ditherSelector)
        addChild(ditherOptions)
        view.addSubview(ditherOptions.view)
    }
    
    private func configureNavBar(){
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "Dither Example"
        
        let saveImageButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveImageToGallery))
        let addImageButton = UIBarButtonItem(title: "Gallery", image: UIImage(systemName: "photo"), target: self, action: #selector(openGallery))
        
        self.navigationItem.rightBarButtonItems = [addImageButton, saveImageButton]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action:  #selector(removeDither))
        self.navigationItem.leftBarButtonItem?.tintColor = .systemRed
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
    
    private func addApplyConstraints(){
        let constraints = [
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            applyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            applyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            applyButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
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
            ditherOptions.view.leadingAnchor.constraint(equalTo:  view.leadingAnchor),
            ditherOptions.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ditherOptions.view.bottomAnchor.constraint(equalTo: applyButton.topAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    

    
}
