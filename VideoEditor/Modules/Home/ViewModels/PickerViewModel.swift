//
//  PickerViewModel.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/4/28.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import Photos
import RxSwift
import RxCocoa

let AssetImageDirName = "AssetImage"

class PickerViewModel: ViewModelType {
    struct Input {
        var trigger: Driver<Void>
        var selection: Driver<IndexPath>
    }
    struct Output {
        var models: Driver<[AssetModel]>
        var authrizedStatus: Driver<PHAuthorizationStatus>
    }
    
    var modelsSubject: PublishSubject<[AssetModel]> = PublishSubject()
    
    var models: [AssetModel] = [AssetModel]()
    
    func transform(input: Input) -> Output {
                
        let outputStatus = input.trigger.flatMap { [weak self] (_) -> Driver<PHAuthorizationStatus> in
            return (self?.checkStatus())!.asDriver(onErrorDriveWith: Driver.empty())
        }
                        
        return Output(models: modelsSubject.asDriver(onErrorJustReturn: [AssetModel]()), authrizedStatus: outputStatus)
    }
    
    func checkStatus() -> PublishSubject<PHAuthorizationStatus> {
        let subject = PublishSubject<PHAuthorizationStatus>()
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (aStatus) in
                if aStatus == .authorized {
                    self?.loadPhoto()
                } else {
                    subject.onNext(aStatus)
                }
            }
        case .authorized:
            loadPhoto()
        default:
            subject.onNext(status)
        }
        return subject
    }
    
    func loadPhoto() {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects {[weak self] (collection, index, stop) in
            if collection.estimatedAssetCount > 0 {
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    let result = PHAsset.fetchAssets(in: collection, options: fetchOption)
                    let albumModel = AlbumModel(result: result, name: collection.localizedTitle ?? "", isCameraRoll: true, needFetchAssets: true)
                    self?.modelsSubject.onNext(albumModel.models)
                    self?.models = albumModel.models
                }
            }
        }

    }
    
    
    func isCameraRollAlbum(_ collection: PHAssetCollection) -> Bool {
//        var versionString = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "")
//        if versionString.count <= 1 {
//            versionString = versionString.appending("00")
//        } else if versionString.count <= 2 {
//            versionString = versionString.appending("0")
//        }
//        let version = Float(versionString)
        
        return collection.assetCollectionSubtype == .smartAlbumUserLibrary
    }
    
    class func getPhoto(with asset: PHAsset,
                        width: CGFloat,
                        completion: @escaping (UIImage, [AnyHashable: Any], Bool) -> (Void)) -> PHImageRequestID {
        var imageSize: CGSize = CGSize(width: 200, height: 200)
        
        if width >= ScreenWidth {
            let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            let photoWidth = width * aspectRatio
           
            imageSize = CGSize(width: photoWidth, height: photoWidth / aspectRatio)
        }
        
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        
        let requestID = PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: option) { (image, info) in
            if info?[PHImageResultIsInCloudKey] != nil {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                options.resizeMode = .fast
                PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (data, dataUTI, oriention, info) in
                    if data != nil {
                        var result = UIImage(data: data!)
                        if result == nil {
                            result = image
                        }
                        completion(result!, info!,false)
                    }
                }
            } else {
                if image != nil {
                    completion(image!, info!,false)
                }
            }
        }
        return requestID
    }
    
    func loadAVAssets(models: [AssetModel], completion: @escaping SingleParamsCallback<[AVAsset]>, error: @escaping SingleParamsCallback<Bool>) {
        var assets = [AVAsset](repeating: AVAsset(url: URL(fileURLWithPath: "")), count: models.count)
        var count = 0
        for (index, model) in models.enumerated() {
            if model.type == .Video {
                let option = PHVideoRequestOptions()
                option.isNetworkAccessAllowed = true
                PHImageManager.default()
                    .requestAVAsset(forVideo: model.asset, options: option) { (result, audioMix, info) in
                    guard let asset = result else {
                        error(false)
                        return
                    }
                        
                    asset.loadValuesAsynchronously(forKeys: [AVAssetDurationKey, AVAssetTracksKey, AVAssetCommonMetadataKey]) {[weak asset] in
                        guard let weakAsset = asset else {return}
                        assets[index] = weakAsset
                        count += 1
                        if count == models.count {
                            completion(assets)
                        }
                    }
                        

                }
            } else {
                let option = PHImageRequestOptions()
                option.isNetworkAccessAllowed = true
                PHImageManager.default()
                    .requestImage(for: model.asset, targetSize: CGSize(width: model.asset.pixelWidth, height: model.asset.pixelHeight), contentMode: .aspectFit, options: option) { [weak self](image, info) in
                        guard let strongSelf = self else {return}
                        let value = info?[PHImageResultIsDegradedKey] as? NSNumber
                        if value?.intValue != 1  {
                            if image != nil {
                                // 获得的是高清图片
                                let asset = strongSelf.saveImageToSandBox(image: image!)
                                assets[index] = asset
                                count += 1
                                if count == models.count {
                                    completion(assets)
                                }
                            } else {
                                error(false)
                            }
                        } else {
                            return
                        }
                }
            }
        }
    }
    
    
    func saveImageToSandBox(image: UIImage) -> AVURLAsset {
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let dirpath = docPath?.appending("/\(AssetImageDirName)")
        if FileManager.default.fileExists(atPath: dirpath!) == false {
            try! FileManager.default.createDirectory(atPath: dirpath!, withIntermediateDirectories: true, attributes: nil)
        }
        let name = "\(Int(Date().timeIntervalSince1970)).jpg"
        let fullPath = dirpath?.appending("/\(name)")
        try! FileManager.default.createFile(atPath: fullPath!, contents: image.jpegData(compressionQuality: 1), attributes: nil)
        let url = URL(fileURLWithPath: fullPath!)
        return AVURLAsset(url: url)
    }
}
