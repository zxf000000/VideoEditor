//
//  PickerFlowLayout.swift
//  VideoEditor
//
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit

class PickerFlowLayer: UICollectionViewFlowLayout {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
//        let minSpace = 10
        let itemWidth = (ScreenWidth - 40) / 3 - 0.1
        itemSize = CGSize(width: itemWidth, height: itemWidth)
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
