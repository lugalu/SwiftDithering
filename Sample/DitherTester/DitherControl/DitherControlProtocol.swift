//Created by Lugalu on 03/08/23.

import UIKit

protocol DitherControlProtocol: UIViewController{
    func retrivedDitheredImage(for: UIImage?) async throws -> UIImage?
}
