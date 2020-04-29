//
//  PickerCollectionViewCell.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/4/28.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit
import Photos

class PickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBOutlet weak var selectButton: UIButton!
    
    var didTapSelectButtonBlock: SingleParamsCallback<Bool>?
    
    var imageRequestID: Int32?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        previewImageView.layer.masksToBounds = true
        
    }
    
    func updateModel(assetModel: AssetModel) {
        if assetModel.timeLength == "0.0" {
            timeLabel.isHidden = true
        } else {
            timeLabel.isHidden = false
            timeLabel.text = assetModel.timeLength
        }
        
        let requestID = PickerViewModel.getPhoto(with: assetModel.asset, width: 200) { [weak self] (image, info, flag) -> (Void) in
            self?.previewImageView.image = image
        }
        if requestID != self.imageRequestID && imageRequestID != nil {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        imageRequestID = requestID
        selectButton.isSelected = assetModel.isSelected
        
    }
    
    @IBAction func tapSelectButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        didTapSelectButtonBlock?(sender.isSelected)
    }
    
}
