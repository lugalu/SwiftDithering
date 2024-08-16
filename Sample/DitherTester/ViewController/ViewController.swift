//
//  ViewController.swift
//  DitherTester
//
//  Created by Lugalu on 23/07/23.
//

import UIKit
import PhotosUI
import SwiftDithering

class ViewController: UIViewController {
    let defaultImage = UIImage(named: "ColoredImageTest 1")
    var galleyImage: UIImage? = nil
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .clear
        imgView.layer.cornerRadius = 5
        imgView.layer.masksToBounds = true
        imgView.layer.borderColor = UIColor.gray.cgColor
        imgView.layer.borderWidth = 1
        imgView.isUserInteractionEnabled = true
        
        return imgView
    }()
    
    let ditherSelector: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    let ditherOptions: DitherPageController = {
        let pageView = DitherPageController()
        return pageView
    }()

    let applyButton: CustomButton = {
        let btn = CustomButton(configuration: .filled())
        btn.configure(withTitle: "Apply Dither", for: .normal)
        return btn
    }()
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        setupSegmentedControl()
        setupPageController()
        imageView.image = defaultImage
        applyButton.addTarget(self, action: #selector(applyDither), for: .touchUpInside)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onImageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
    }    
}







