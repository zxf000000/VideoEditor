//
//  PinchGestureHandlerImpl.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/5/14.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit

class PinchGestureHandlerImpl: GestureRecognizerHandler {
    var gestureRecorgnizer: UIGestureRecognizer {
        get {
            return _gestureRecognizer
        }
    }

    private var _gestureRecognizer: UIPinchGestureRecognizer!
    private var collectionView: UICollectionView!
    
    required init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        
    }
    
    func initGes() {
        _gestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(gestureHandle(_:)))
        collectionView.addGestureRecognizer(_gestureRecognizer)

    }
    
    @objc
    func gestureHandle(_ ges: UIPinchGestureRecognizer) {
        switch ges.state {
        case .began:
            gestureHandleBegin()
        case .changed:
            gestureHandleChange()
        case .cancelled:
            gestureHandleEnd()
        case .ended:
            gestureHandleEnd()
        case .failed:
            gestureHandleEnd()
        default:
            break
        }
    }
    
    func gestureHandleBegin() {
        
    }
    func gestureHandleChange() {
        
    }
    func gestureHandleEnd() {
        
    }
}
