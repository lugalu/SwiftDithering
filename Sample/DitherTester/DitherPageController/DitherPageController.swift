//Created by Lugalu on 07/08/23.

import UIKit

class DitherPageController: UIPageViewController {
    lazy var lastSelectedIndex = 0
    lazy var ditherControllers: [UIViewController & DitherControlProtocol] = []
    
    func configure(owner: UIPageViewControllerDelegate & UIPageViewControllerDataSource,
                   ditherViewControllers: [UIViewController & DitherControlProtocol] = [
        OrderedDitherViewController(),
        ErrorDifusionViewController()
    ]){
        self.delegate = owner
        self.dataSource = owner
        self.ditherControllers = ditherViewControllers
        
        for gesture in self.gestureRecognizers{
            self.view.removeGestureRecognizer(gesture)
        }
        
        self.setViewControllers([ditherViewControllers[0]], direction: .forward, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
