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
    
    var widthPerSecond: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let duration = CMTimeGetSeconds(totalDuration)
        let durationInt = Int(duration * 10)
        let seconds = durationInt / 10
        widthPerSecond = (bounds.size.width / CGFloat(durationInt))  * 10
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        var centerX: CGFloat = widthPerSecond / 2
        let centerY: CGFloat = 15
        
        for _ in 0..<seconds {
            print("\(centerX)")
            context?.addArc(center: CGPoint(x: centerX, y: centerY), radius: 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            context?.drawPath(using: .fill)
            centerX += widthPerSecond
        }
        centerX = 0
        for i in 0..<seconds {
            let textCenter = CGPoint(x: centerX , y: centerY)
            let str = "\(i)s"
            let textToDraw = str as NSString
            let size = textToDraw.boundingRect(with: CGSize(width: 100, height: 100), options: .usesFontLeading, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8)], context: nil).size
            textToDraw.draw(in: CGRect(x: textCenter.x - size.width / 2,
                                       y: textCenter.y - size.height / 2,
                                       width: size.width,
                                       height: size.height),
                            withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8),
                                             NSAttributedString.Key.foregroundColor: UIColor.white])
            centerX += widthPerSecond
        }
    }

}
