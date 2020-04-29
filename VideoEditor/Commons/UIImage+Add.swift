//
//  UIImage+Add.swift
//  VideoEditor
//
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit

extension UIImage {
    class func generateImage(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
