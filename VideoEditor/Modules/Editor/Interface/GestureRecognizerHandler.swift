//
//  GestureProtocol.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/5/14.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit

protocol GestureRecognizerHandler {
    var gestureRecorgnizer: UIGestureRecognizer { get }
    func gestureHandleBegin()
    func gestureHandleEnd()
    func gestureHandleChange()
    init(collectionView: UICollectionView)
}
