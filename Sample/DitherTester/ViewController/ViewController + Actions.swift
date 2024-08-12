//Created by Lugalu on 03/08/23.

import UIKit

extension ViewController{
    func applyImage(_ image: UIImage){
        DispatchQueue.main.async {
            self.galleyImage = image
            self.imageView.image = image
        }
    }
    
    @objc func saveImageToGallery(){
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    @objc func applyDither(){
        Task{
            do{
                let index = self.ditherSelector.selectedSegmentIndex
                let ditherer = ditherOptions.ditherControllers[index]
                
                let newImage = try await ditherer.retrivedDitheredImage(for: self.imageView.image)
                DispatchQueue.main.async {
                    self.imageView.image = newImage
                }
            }catch{
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func removeDither(){
        imageView.image = galleyImage ?? defaultImage
    }
    
    func onOptionChange(){
        guard let vc = self.pageViewController(ditherOptions, viewControllerBefore: ditherOptions.viewControllers?.first ?? UIViewController()) else { return }
        
        let direction: UIPageViewController.NavigationDirection = ditherSelector.selectedSegmentIndex > ditherOptions.lastSelectedIndex ? .forward : .reverse
        ditherOptions.lastSelectedIndex = ditherSelector.selectedSegmentIndex
        ditherOptions.setViewControllers([vc], direction: direction, animated: false)
    }
    
    @objc func onImageViewTapped(){
        let vc = ImageZoomViewController()
        vc.configure(image: imageView.image)
        vc.modalPresentationStyle = .automatic
        self.present(vc, animated: true)
    }
}
