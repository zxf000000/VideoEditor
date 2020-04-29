//
//  HUDManager.swift
//  VideoEditor
//
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import MBProgressHUD
import UIKit

extension MBProgressHUD {
    class func xf_showProgress() -> MBProgressHUD {
        let HUD = MBProgressHUD.showAdded(to: getAppDelegate().window!, animated: true)
        return HUD
    }
    
    class func xf_showProgress(text: String) -> MBProgressHUD {
        let HUD = MBProgressHUD.showAdded(to: getAppDelegate().window!, animated: true)
        HUD.label.text = text
        return HUD
    }
    
    class func xf_showText(text: String) -> MBProgressHUD {
        let HUD = MBProgressHUD.showAdded(to: getAppDelegate().window!, animated: true)
        HUD.mode = MBProgressHUDMode.text
        HUD.hide(animated: true, afterDelay: 1)
        return HUD
    }
    
    func xf_showText(text: String) {
        self.mode = .text
        self.label.text = text
        self.hide(animated: true, afterDelay: 1)
    }
    
    
    class func getAppDelegate() -> AppDelegate {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate
        }
        return AppDelegate()
    }
}
