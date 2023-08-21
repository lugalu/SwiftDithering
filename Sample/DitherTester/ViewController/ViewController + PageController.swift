//Created by Lugalu on 03/08/23.

import UIKit

extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func setupSegmentedControl(){
        let titles = ["Ordered", "Error Difusion", "threshold"]
        
        for i in 0..<titles.count {
            let action = UIAction(title: titles[i]){ (action) in
                self.onOptionChange()
            }
            
            ditherSelector.insertSegment(action: action, at: i, animated: true)
        }
        ditherSelector.selectedSegmentIndex = 0
    }
    
    func setupPageController(){
        ditherOptions.configure(owner: self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = ditherSelector.selectedSegmentIndex
        return ditherOptions.ditherControllers[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    

}
