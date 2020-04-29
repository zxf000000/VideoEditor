//
//  PickerVIewController.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/4/28.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import AVFoundation

class PickerViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var exportSubject: PublishSubject<[AVAsset]>?
    
    var viewModel: PickerViewModel = PickerViewModel()
    
    var trigger: PublishSubject<Void> = PublishSubject()
    
    var disposeBag: DisposeBag! = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exportButton.setBackgroundImage(UIImage.generateImage(with: UIColor.systemRed), for: .normal)
        
        bindViewModel()
    }
    
    @IBAction func tapCheckButton(_ sender: Any) {
        
        let HUD = MBProgressHUD.xf_showProgress()
        
        var selectedModels = [AssetModel]()
        for model in viewModel.models {
            if model.isSelected {
                selectedModels.append(model)
            }
        }
        // loadAssetWithModel
        viewModel.loadAVAssets(models: selectedModels, completion: { [weak self] (assets) in
            DispatchQueue.main.async {
                HUD.xf_showText(text: "处理成功")
                self?.dismiss(animated: false, completion: nil)
                self?.exportSubject?.onNext(assets)
            }

        }) { (error) in
            if error == false {
                HUD.xf_showText(text: "处理失败")
            } else {
                HUD.xf_showText(text: "处理成功")
            }
        }
        
    }
    func bindViewModel() {
        let input = PickerViewModel.Input(trigger: trigger.asDriver(onErrorJustReturn: ()), selection: collectionView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)

        output.models.flatMap({ [weak self] (models) -> Driver<[AssetModel]> in
            var newModels = [AssetModel]()
            for model in models {
                if self?.segmentView.selectedSegmentIndex == 0 && model.type == .Video {
                    newModels.append(model)
                }
                if self?.segmentView.selectedSegmentIndex == 1 && model.type == .Photo {
                    newModels.append(model)
                }
            }
            return Driver.just(newModels)
        })
            .drive(collectionView.rx.items(cellIdentifier: "PickerCollectionViewCell", cellType: PickerCollectionViewCell.self)) { [weak self] (row, element, cell) in
                guard let strongSelf = self else {return}
                cell.updateModel(assetModel: element)
                cell.didTapSelectButtonBlock = { [weak strongSelf] (isSelected) in
                      guard let sSelf = strongSelf else {return}
                     var model = sSelf.viewModel.models[row]
                     model.isSelected = isSelected
                     sSelf.viewModel.models[row] = model
                 }
            }
            .disposed(by: disposeBag)
        
        output.authrizedStatus.flatMap { (status) -> Driver<Bool> in
            var result = false
            if status != .authorized {
                result = false
            } else {
                result = true
            }
            return Driver.just(result)
            }
            .drive(emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        trigger.onNext(())
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

