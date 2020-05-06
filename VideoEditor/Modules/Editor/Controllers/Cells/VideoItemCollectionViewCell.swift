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
        images.removeAll()
        let generate = AVAssetImageGenerator(asset: asset)
        let duration = CMTimeGetSeconds(asset.duration)
        let intDuration = Int(duration)
        var times = [NSValue]()
        for i in 0..<intDuration {
            times.append(NSValue(time: CMTimeMake(value: Int64(i), timescale: 1)))
        }
        if duration > Double(intDuration) {
            times.append(NSValue(time: CMTimeMake(value: Int64(intDuration), timescale: 1)))
        }
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
            if self?.images.count ?? 0 == times.count {
                DispatchQueue.main.async {
                    self?.setNeedsLayout()
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        update()
        
    }
    
    func update() {
            for layer in self.imageLayers {
                layer.removeFromSuperlayer()
            }
            self.imageLayers.removeAll()
            
            for (index, image) in self.images.enumerated() {
                let x = CGFloat(index) * SinglePreviewPicWidth
                let y = 0
                let width = SinglePreviewPicWidth
                let height = SinglePreviewPicWidth
                                
                let layer = CALayer()
                layer.backgroundColor = UIColor.yellow.cgColor
                layer.contents = image.cgImage
                layer.frame = CGRect(x: x, y: CGFloat(y), width: width, height: height)
                layer.contentsGravity = .resizeAspectFill

                layer.masksToBounds = true
                layer.borderWidth = 0.5
                layer.borderColor = UIColor.white.cgColor
                self.contentView.layer.addSublayer(layer)
                self.imageLayers.append(layer)
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
