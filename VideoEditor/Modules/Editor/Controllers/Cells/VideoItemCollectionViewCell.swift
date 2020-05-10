//
//  VideoItemCollectionViewCell.swift
//  FifteenSeconds_Swift
//
//  Created by 壹九科技1 on 2020/4/23.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation

class VideoItemCollectionViewCell: UICollectionViewCell {
    //    var itemView: TimeLineItemView!
    var maxTimeRagne: CMTimeRange!
    //    var trimmerImageView: UIImageView!
    var videoItem: VideoItem?
    
    var images: [UIImage] = [UIImage]()
    
    var imageLayers: [CALayer] = [CALayer]()
    
    var imageGenerate: AVAssetImageGenerator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    
    func updateItem(videoItem: VideoItem) {
        self.videoItem = videoItem
        guard let asset = videoItem.asset else {return}
        self.videoItem?.didSetLastScale = {[weak self] in
            guard let strongSelf = self else {return}
            strongSelf.generateImages()
        }
        imageGenerate = AVAssetImageGenerator(asset: asset)
        generateImages()
    }
    
    func generateImages() {
        images.removeAll()
        
        guard let asset = videoItem?.asset, let generate = imageGenerate else {return}
        imageGenerate?.cancelAllCGImageGeneration()
        let duration = CMTimeGetSeconds(asset.duration)
        var times = [NSValue]()
        
        let scale = videoItem?.scale ?? 1
        // 计算时间间隔
        let timeSpace = 1 / scale
        let cmTimeSpace = CMTimeMake(value: Int64(timeSpace * 30), timescale: 30)
        // 取图片个数
        let scaleDuration = CGFloat(duration) * scale
        let intScaleDuration = Int(scaleDuration)
        var tmpTime = CMTime.zero
        for _ in 0..<intScaleDuration {
            times.append(NSValue(time: tmpTime))
            tmpTime = CMTimeAdd(tmpTime, cmTimeSpace)
        }
        if scaleDuration > CGFloat(Double(intScaleDuration)) {
            times.append(NSValue(time: tmpTime))
        }
        

        generateLayers(count: times.count)
        
        generate.maximumSize = CGSize(width: SinglePreviewPicWidth * ScreenScale, height: SinglePreviewPicWidth * ScreenScale)
        generate.requestedTimeToleranceAfter = .zero
        generate.requestedTimeToleranceBefore = .zero
        generate.generateCGImagesAsynchronously(forTimes: times) { [weak self] (time, image, actualTime, result, error) in
            var resultImage: UIImage?
            if image != nil {
                resultImage = UIImage(cgImage: image!)
                self?.images.append(resultImage!)
            } else {
                resultImage = UIImage.generateImage(with: .brown)!
                self?.images.append(resultImage!)
            }
            // 直接添加 layer
            DispatchQueue.main.async {
                if let index = times.firstIndex(of: NSValue(time: time)), let layer = self?.imageLayers[index] {
                    layer.contents = image
                }
            }
            if self?.images.count ?? 0 == times.count {
                DispatchQueue.main.async {
                    self?.setNeedsLayout()
                }
            }
        }
    }
    
    func generateLayers(count: Int) {
        if imageLayers.count < count {
            for layer in imageLayers {
                layer.removeFromSuperlayer()
            }
            imageLayers.removeAll()
        }
        let y = 0
        let width = SinglePreviewPicWidth
        let height = SinglePreviewPicWidth
        if imageLayers.count == 0 {
            for i in 0..<count {
                let x = CGFloat(i) * SinglePreviewPicWidth
                let layer = CALayer()
                layer.frame = CGRect(x: x, y: CGFloat(y), width: width, height: height)
                layer.contentsGravity = .resizeAspectFill
                
                layer.masksToBounds = true
                layer.borderWidth = 0.5
                layer.borderColor = UIColor.white.cgColor
                imageLayers.append(layer)
                contentView.layer.addSublayer(layer)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    func update() {
        
        imageGenerate?.cancelAllCGImageGeneration()
        
        // 根据 scale 计算当前每秒需要几张图片
        let y = 0
        let width = SinglePreviewPicWidth
        let height = SinglePreviewPicWidth
//        for (index, image) in self.images.enumerated() {
//            let x = CGFloat(index) * SinglePreviewPicWidth
//
//
//            let layer = CALayer()
//            layer.backgroundColor = UIColor.yellow.cgColor
//            layer.contents = image.cgImage
//            layer.frame = CGRect(x: x, y: CGFloat(y), width: width, height: height)
//            layer.contentsGravity = .resizeAspectFill
//
//            layer.masksToBounds = true
//            layer.borderWidth = 0.5
//            layer.borderColor = UIColor.white.cgColor
//            self.contentView.layer.addSublayer(layer)
//            self.imageLayers.append(layer)
//        }
        
        guard let lastX = imageLayers.last?.frame.maxX else {return}
        if lastX < bounds.width {
            let dif = bounds.width - lastX
            let extraCount = dif / SinglePreviewPicWidth
            let extraCountInt = Int(extraCount) + 1
            for i in 0..<extraCountInt {
                let layer = CALayer()
                layer.backgroundColor = UIColor.yellow.cgColor
                layer.contents = images.last!.cgImage
                layer.frame = CGRect(x: lastX + CGFloat(i) * SinglePreviewPicWidth, y: CGFloat(y), width: width, height: height)
                layer.contentsGravity = .resizeAspectFill
                
                layer.masksToBounds = true
                layer.borderWidth = 0.5
                layer.borderColor = UIColor.white.cgColor
                
                self.contentView.layer.addSublayer(layer)
                self.imageLayers.append(layer)
            }
        }
    }

    
    func setup() {
        //        itemView = TimeLineItemView(frame: bounds)
        //        contentView.addSubview(itemView)
        
        backgroundColor = UIColor.xf_RandomColor()
        

        
    }
    
    
    func isPointInDragHandle(point: CGPoint) -> Bool {
        return false
    }
    
    
}
