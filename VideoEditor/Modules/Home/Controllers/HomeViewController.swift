//
//  HomeViewController.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/4/28.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var beginView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    @IBAction func beginEdit(_ sender: Any) {
        
        let pickerVC = R.storyboard.home.pickerViewController()
        present(pickerVC!, animated: true, completion: nil)
        
    }
    func setupUI() {
        navigationItem.title = "Home"
    }

}
