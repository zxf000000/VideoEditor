//
//  UIAlertController+Add.swift
//  HealthInnovationTech
//
//  Copyright © 2020 YJKJ. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    /// 简便方法构造AlertController
    class func xf_showAlert(_ title: String?, message: String?, style: UIAlertController.Style, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
