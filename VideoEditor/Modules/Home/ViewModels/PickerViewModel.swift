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

class PickerViewModel: ViewModelType {
    struct Input {
        var trigger: Driver<Void>
    }
    struct Output {
        var models: Driver<[AssetModel]>
        var authrizedStatus: Driver<PHAuthorizationStatus>
    }
    
    var statusSubject: PublishSubject<PHAuthorizationStatus> = PublishSubject()
    
    func transform(input: Input) -> Output {
        
        
        
        return Output(models: Driver.just([AssetModel]()), authrizedStatus: statusSubject.asDriver(onErrorJustReturn: .denied))
    }
    
    func checkStatus() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (aStatus) in
                self?.statusSubject.onNext(aStatus)
            }
        case .authorized:
            loadPhoto()
        default:
            statusSubject.onNext(status)
        }
    }
    
    func loadPhoto() {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let myPhotoAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: fetchOption)
        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: fetchOption)
        let syncedAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumSyncedAlbum, options: fetchOption)
        let shareAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: fetchOption)
        var allAlbums: [PHFetchResult<PHAssetCollection>] = [myPhotoAlbum, smartAlbum, syncedAlbum, shareAlbum]
        if let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: fetchOption) as? PHFetchResult<PHAssetCollection> {
            allAlbums.append(topLevelUserCollections)
        }

        for fetchResult in allAlbums {
            fetchResult.enumerateObjects { (collection, index, flag) in
                if !collection.isKind(of: PHAssetCollection.self) {
                    flag.pointee = true
                }
                if collection.estimatedAssetCount <= 0 {
                    flag.pointee = true
                }
                let result = PHAsset.fetchAssets(in: collection, options: fetchOption)
                if result.count < 1 {
                    flag.pointee =  true
                }
                
                
            }
            
        }
        
        
    }
}
