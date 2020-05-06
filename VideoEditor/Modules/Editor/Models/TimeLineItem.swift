//
//  TimeLineItem.swift
//  FifteenSeconds_Swift
//
//  Created by 壹九科技1 on 2020/4/22.
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation
import CoreMedia

class TimeLineItem {
    var timeRange: CMTimeRange?
    var startTimeInTimeLine: CMTime?
    
    private var _scale: CGFloat = 1.0
    
    // 缩放系数
    var scale: CGFloat {
        set {
            if newValue > 30 {
                _scale = 30
            } else {
                _scale = newValue
            }
        }
        get {
            return _scale
        }
    }
    var lastScale: CGFloat = 1.0
    
    init() {
        timeRange = .invalid
        startTimeInTimeLine = .invalid
    }
}
