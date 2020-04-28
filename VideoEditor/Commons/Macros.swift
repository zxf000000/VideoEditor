//
//  Marcor.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/4/28.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit

/// 无参数返回值block
typealias NoneParamsCallback = (() -> Void)
/// 单个参数无返回值block
typealias SingleParamsCallback<T> = ((T) -> Void)
/// 单个参数返回值block
typealias SingleParamsWithReturnCallBack<T,R> = ((T) -> R)
/// 无参数有返回值block
typealias SingleReturnCallback<R> = (() -> R)

func SystemImage(_ name: String) -> UIImage? {
    return UIImage(systemName: name)
}
