//
//  AlbumModel.swift
//  VideoEditor
//
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import Photos


class AlbumModel {
    var name: String!
    var count: Int!
    var result: PHFetchResult<PHAsset>!
    var models: [AssetModel]!
    var selectedModels: [AssetModel]?
    var selectedCount: Int?
    var isCameraRoll: Bool!
    
    var loadCompletion: NoneParamsCallback?
    
    init(result: PHFetchResult<PHAsset>,
         name: String,
         isCameraRoll: Bool,
         needFetchAssets: Bool,
         loadCompletion: @escaping SingleParamsCallback<[AssetModel]>) {
        if needFetchAssets {
            getAssets(from: result) { [weak self] (models) in
                self?.models = models
                loadCompletion(models)
            }
        }
        self.name = name
        self.isCameraRoll = isCameraRoll
        self.count = result.count
    }
    
    func getAssets(from result: PHFetchResult<PHAsset>, complete: @escaping SingleParamsCallback<[AssetModel]>) {
        var models = [AssetModel]()
        result.enumerateObjects { [weak self] (asset, index, stop) in
            guard let strongSelf = self else {return}
            var timelength = "0.0"
            let type = strongSelf.getAssetType(asset: asset)
            if type == .Video {
                timelength = strongSelf.getTimeLength(asset: asset)
            }
            let assetModel =
                AssetModel(asset: asset, type: type, isSelected: false, timeLength: timelength)
            models.append(assetModel)
        }
        complete(models)
    }
    
    func getTimeLength(asset: PHAsset) -> String {
        var newTime: String = ""
        let duration = asset.duration
        if duration < 10 {
            newTime = "0:0\(Int(duration))"
        } else if (duration < 60) {
            newTime = "0:\(Int(duration))"
        } else {
            let min = duration / 60;
            let sec = duration - (min * 60);
            if sec < 10 {
                newTime = "\(min):0\(sec)"
            } else {
                newTime = "\(min):\(sec)"
            }
        }
        return newTime;
    }
    
    func getAssetType(asset: PHAsset) -> AssetModelMediaType {
        var type = AssetModelMediaType.Photo
        if asset.mediaType == .video { type = .Video}
        if asset.mediaType == .audio { type = .Audio}
        if asset.mediaType == .image {
            type = (asset.value(forKey: "filename") as! String).hasSuffix("GIF") ? .Gif : .Photo
        }
        return type
    }
}
