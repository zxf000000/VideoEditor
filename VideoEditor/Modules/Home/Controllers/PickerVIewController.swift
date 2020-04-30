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

    var filteredModels: [AssetModel]?
    
    var selectedModels: [AssetModel] = [AssetModel]()
    
    var binder: Binder<[AssetModel]> {
        return Binder(self) { (vc, _) in
            vc.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exportButton.setBackgroundImage(UIImage.generateImage(with: UIColor.systemRed), for: .normal)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        bindViewModel()
    }
    
    @IBAction func tapCheckButton(_ sender: Any) {
        
        
        if selectedModels.count == 0{
            dismiss(animated: true, completion: nil)
            return
        }
        let HUD = MBProgressHUD.xf_showProgress()

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

        output
            .videoModels
            .drive(binder)
            .disposed(by: disposeBag)
        output
            .imageModels
            .drive(binder)
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
        
        
        segmentView
            .rx
            .selectedSegmentIndex.subscribe(onNext: { [weak self] (index) in
                self?.trigger.onNext(())
            })
            .disposed(by: disposeBag)
        
    }
    
    func didTapSelectButton(index: Int, selected: Bool) {
        if segmentView.selectedSegmentIndex == 0 {
            var model = viewModel.videoModels[index]
            model.isSelected = selected
            viewModel.videoModels[index] = model
            if selected {
                selectedModels.append(model)
            } else {
                selectedModels.removeAll { (aModel) -> Bool in
                    aModel.asset == model.asset
                }
            }
        } else {
            var model = viewModel.imageModels[index]
            model.isSelected = selected
            viewModel.imageModels[index] = model
            if selected {
                selectedModels.append(model)
            } else {
                selectedModels.removeAll { (aModel) -> Bool in
                    aModel.asset == model.asset
                }
            }
        }
        
        
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segmentView.selectedSegmentIndex == 0 ? viewModel.videoModels.count : viewModel.imageModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickerCollectionViewCell", for: indexPath) as! PickerCollectionViewCell
        cell.updateModel(assetModel: (segmentView.selectedSegmentIndex == 0 ? viewModel.videoModels[indexPath.item] : viewModel.imageModels[indexPath.item]))
        cell.didTapSelectButtonBlock = { [weak self] (isSelected) in
            guard let strongSelf = self else {return}
            strongSelf.didTapSelectButton(index: indexPath.item, selected: isSelected)
        }
        return cell
    }
    
}

