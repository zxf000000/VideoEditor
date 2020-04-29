//
//  AssetModel.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/4/28.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import Photos

enum AssetModelMediaType: Int {
    case Photo = 0
    case Video
    case LivePhoto
    case Audio
    case Gif
}

struct AssetModel {
    var asset: PHAsset!
    var type: AssetModelMediaType!
    var isSelected: Bool = false
    var timeLength: String!
    
    
}
