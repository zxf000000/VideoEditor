    var width: CGFloat = 20
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2)
        context?.setStrokeColor(UIColor.blue.cgColor)
        context?.setFillColor(UIColor.green.cgColor)
        for i in 0..<10 {
            context?.addArc(center: CGPoint(x: CGFloat(i) * width + 20, y: 50), radius: 5, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            context?.drawPath(using: .fill)
        }
        
        for i in 0..<10 {
            let str = "\(i)s"
            let size = (str as NSString).boundingRect(with: CGSize(width: 100, height: 100), options: .usesFontLeading, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)], context: nil).size
            let fWidth = size.width
            let height = size.height
                        
            (str as NSString).draw(in: CGRect(x: CGFloat(i) * width + fWidth / 2, y: 50 - height / 2, width: fWidth, height: height), withAttributes: [NSAttributedString.Key.foregroundColor: UIColor.red,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
        }
        
    }
