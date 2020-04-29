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

let ScreenWidth = UIScreen.main.bounds.width
let ScreenScale = UIScreen.main.scale
let ScreenHeight = UIScreen.main.bounds.size.height


let StatusBarHeight = UIApplication.shared.statusBarFrame.size.height
let NavigationBarHeight: CGFloat = 44.0
let NavigationStatusBarHeight = NavigationBarHeight + StatusBarHeight


let TabbarHeight: CGFloat = 49
let BottomSafeAreaHeight: CGFloat = StatusBarHeight > 20 ? 34 : 0
let TabbarTotalHeight: CGFloat = TabbarHeight + BottomSafeAreaHeight

func SystemImage(_ name: String) -> UIImage? {
    return UIImage(systemName: name)
}
