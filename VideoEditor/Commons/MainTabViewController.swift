//
//  MainTabViewController.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/4/28.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = R.storyboard.home.homeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC!)
        
        let captureVC = R.storyboard.capture.captureViewController()
        let captureNav = UINavigationController(rootViewController: captureVC!)
        
        let settingVC = R.storyboard.setting.settingViewController()
        let settingNav = UINavigationController(rootViewController: settingVC!)
        
        
        
        self.addChild(homeNav)
        self.addChild(captureNav)
        self.addChild(settingNav)
        
        homeNav.tabBarItem = UITabBarItem(title: nil, image: SystemImage("house"), selectedImage: SystemImage("house.fill"))
        captureNav.tabBarItem = UITabBarItem(title: nil, image: SystemImage("camera"), selectedImage: SystemImage("camera.fill"))
        settingNav.tabBarItem = UITabBarItem(title: nil, image: SystemImage("wrench"), selectedImage: SystemImage("wrench.fill"))
        
    }

}
