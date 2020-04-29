//
//  HomeViewController.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/4/28.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class HomeViewController: UIViewController {

    @IBOutlet weak var beginView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var exportedAssets: PublishSubject<[AVAsset]> = PublishSubject()
    var disposeBag = DisposeBag()
    
    var binder: Binder<[AVAsset]> {
        return Binder(self) { (vc, assets) in
            let editorVC = R.storyboard.home.editorViewController()
            editorVC?.assets = assets
            editorVC?.modalPresentationStyle = .fullScreen
            vc.present(editorVC!, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        exportedAssets
            .asDriver(onErrorJustReturn: [AVAsset]())
            .drive(binder)
            .disposed(by: disposeBag)
    }
    
    @IBAction func beginEdit(_ sender: Any) {
        
        let pickerVC = R.storyboard.home.pickerViewController()!
        pickerVC.exportSubject = exportedAssets
        present(pickerVC, animated: true, completion: nil)
        
    }
    func setupUI() {
        navigationItem.title = "Home"
    }

}
