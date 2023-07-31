//  Created by Lugalu on 18/07/23.

import Foundation

public enum ImageErrors: Error{
    case failedToRetriveCGImage(localizedDescription:String)
    case failedToCreateContext(localizedDescription:String)
    case failedToOutputImage(localizedDescription:String)
    case failedToConvertimage(localizedDescription:String)
}
