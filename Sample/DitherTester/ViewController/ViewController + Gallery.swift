//Created by Lugalu on 03/08/23.

import UIKit
import PhotosUI

extension ViewController: UIPickerViewDelegate, PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        
        let type: NSItemProviderReading.Type = UIImage.self
        
        result.itemProvider.loadObject(ofClass: type, completionHandler: { reading, error in
            guard let image = reading as? UIImage, error == nil else { return }
            self.applyImage(image)
        })
        
    }
    
    @objc func openGallery(){
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { _ in })
            
        case .restricted:
            handleRestrictedGallery()
            
        case .denied:
            handleDeniedGallery()
            
        case .authorized, .limited:
            handleAuthorizedGalley()
            
        @unknown default:
            return
        }

    }
    
    
    private func handleRestrictedGallery(){
        let alert = UIAlertController(title: "Access Denied", message: "Gallery Access is Restricted", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel)
        
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    private func handleDeniedGallery(){
        let alert = UIAlertController(title: "Access Denied", message: "Gallery Access is Denied, please change in settings", preferredStyle: .alert)
        
        let openSetting = UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }

            UIApplication.shared.open(url,completionHandler: { didFinish in
                alert.dismiss(animated: false)
            })
            
        })
        
        let cancel = UIAlertAction(title: "Cancle", style: .cancel)

        alert.addAction(openSetting)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    private func handleAuthorizedGalley(){
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
    }
    
}
