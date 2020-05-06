//
//  TimelineHeaderView.swift
//  VideoEditor
//
//  Created by mr.zhou on 2020/5/2.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit
import CoreMedia

class TimelineHeaderView: UICollectionReusableView {
    var totalDuration: CMTime = .zero
    var scale: CGFloat = 1
    
    var secondLayers: [CATextLayer] = [CATextLayer]()
    var dotLayers: [CALayer] = [CALayer]()
    
    var widthPerSecond: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        setup()
    }
    
    func setup() {
        
        for layer in secondLayers {
            layer.removeFromSuperlayer()
        }
        for layer in dotLayers {
            layer.removeFromSuperlayer()
        }
        secondLayers.removeAll()
        dotLayers.removeAll()
        
        
        let duration = CMTimeGetSeconds(totalDuration)
        let durationInt = Int(duration * 10)
        let seconds = durationInt / 10
        
        widthPerSecond = (bounds.size.width / CGFloat(durationInt))  * 10
        
        var textLayer = CATextLayer()
        var dotLayer = CALayer()
        var text = NSMutableAttributedString()
        for i in 0..<seconds {
            textLayer = CATextLayer()
            text = NSMutableAttributedString(string: "\(i)s", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                           NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9)])
            textLayer.string = text
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.bounds = CGRect(x: 0, y: 0, width: 15, height: 10)
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.alignmentMode = CATextLayerAlignmentMode.center
            layer.addSublayer(textLayer)
            secondLayers.append(textLayer)
            
            dotLayer = CALayer()
            dotLayer.backgroundColor = UIColor.white.cgColor
            dotLayer.cornerRadius = 2
            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
        
        if durationInt % 10 > 0 {
            dotLayer = CALayer()
            dotLayer.backgroundColor = UIColor.white.cgColor
            dotLayer.cornerRadius = 2
            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
        
        setNeedsLayout()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ scale: CGFloat) {
        let duration = CMTimeGetSeconds(totalDuration)
        let durationInt = Int(duration * 10)
        widthPerSecond = (bounds.size.width / CGFloat(durationInt))  * 10 * scale
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let duration = CMTimeGetSeconds(totalDuration)
        let durationInt = Int(duration * 10)
        widthPerSecond = (bounds.size.width / CGFloat(durationInt))  * 10
        
        
        var centerX: CGFloat = 0
        let centerY: CGFloat = 10
        for (_, layer) in secondLayers.enumerated() {
            layer.position = CGPoint(x: centerX, y: centerY)
            centerX += widthPerSecond
        }
        centerX = widthPerSecond / 2
        for (_, layer) in dotLayers.enumerated() {
            layer.position = CGPoint(x: centerX, y: centerY)
            layer.bounds = CGRect(x: 0, y: 0, width: 4, height: 4)
            centerX += widthPerSecond
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let duration = CMTimeGetSeconds(totalDuration)
        let durationInt = Int(duration * 10)
        let seconds = durationInt / 10
        for i in 0..<seconds {
            let str = "1"
            let label = UILabel()
            
        }
    }

}
