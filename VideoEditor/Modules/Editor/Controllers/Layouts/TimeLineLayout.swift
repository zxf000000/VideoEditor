//
//  TimeLineLayout.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import CoreMedia

protocol UICollectionViewDelegateTimelineLayout: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, willDeleteItemAt indexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    func collectionView(collectionView: UICollectionView, didMoveMediaItemAt indexPath: IndexPath, toIndexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, didAdjustTo width: CGFloat, forItemAt indexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, didAdjustTo position: CGPoint, forItemAt indexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, widthForItemAt indexPath: IndexPath) -> CGFloat
    func collectionView(collectionView: UICollectionView, positionForItemAt indexPath: IndexPath) -> CGPoint
    
    func collectionView(collectionView: UICollectionView, changingScaleTo scale: CGFloat)
    func collectionView(collectionView: UICollectionView, endScaleTo scale: CGFloat)
    
    func currentScaleForCollectionView(collectionView: UICollectionView) -> CGFloat
}

enum PanDirection {
    case right
    case left
}

enum DragMode {
    case none
    case move
    case trim
}

let DEFAULT_TRACK_HEIGHT: CGFloat = TIMELINE_VIDEO_CELL_HEIGHT
let DEFAULT_CLIP_SPACING: CGFloat = 0.0
let TRANSITION_CONTROL_HW: CGFloat = 32.0
let VERTICAL_PADDING: CGFloat = 4.0
let DEFAULT_INSETS = UIEdgeInsets(top: TIMELINE_VIDEO_CELL_HEIGHT, left: ScreenWidth / 2, bottom: 0, right: ScreenWidth / 2)


class TimelineLayout: UICollectionViewLayout {
    var trackHeight: CGFloat? {
        didSet{
            invalidateLayout()
        }
    }
    var clipSpacing: CGFloat? {
        didSet {
            invalidateLayout()
        }
    }
    var trackInsets: UIEdgeInsets? {
        didSet {
            invalidateLayout()
        }
    }
    var recordingAllowed: Bool = false {
        didSet {
            panGestureRecognize?.isEnabled = recordingAllowed
            longPressGestureRecognize?.isEnabled = recordingAllowed
            
            invalidateLayout()
        }
    }
    
    private var currentScale: CGFloat {
        get {
            (self.collectionView?.delegate as! UICollectionViewDelegateTimelineLayout).currentScaleForCollectionView(collectionView: collectionView!)
        }
    }
    
    private var contentSize: CGSize?
    private var caculateLayout: [IndexPath: UICollectionViewLayoutAttributes]?
    private var initialLayout: [IndexPath: UICollectionViewLayoutAttributes]?
    
    private var updates: [Any]?
    private var scaleUnit: CGFloat?
    
    private var panDirection: PanDirection?
    
    private  var panGestureRecognize: UIPanGestureRecognizer?
    private  var longPressGestureRecognize: UILongPressGestureRecognizer?
    private  var tapGestureRecognize: UITapGestureRecognizer?
    private var pinchGestureRecognizer: UIPinchGestureRecognizer?
    
    private var selectedIndexPath: IndexPath?
    private var dragableImageView: UIImageView?
    
    private var swapInProgress: Bool? = false
    private var dragMode: DragMode?
    
    private var trimming: Bool?
    
    private var timelineLayers = [CAShapeLayer]()
        
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        trackInsets = DEFAULT_INSETS
        trackHeight = DEFAULT_TRACK_HEIGHT
        clipSpacing = DEFAULT_CLIP_SPACING
        recordingAllowed = true
        dragMode = .trim
    }
    
    override class var layoutAttributesClass: AnyClass {
        return TimelineLayoutAttribute.self
    }
    
    override func prepare() {
        
        var layoutDic = Dictionary<IndexPath,UICollectionViewLayoutAttributes>()
        var xPos = trackInsets?.left
        var yPos: CGFloat = 0
        let delegate = collectionView?.delegate as? UICollectionViewDelegateTimelineLayout
        var maxTrackWidth: CGFloat = 0.0;

        let trackCount = collectionView?.numberOfSections
        for track in 0..<trackCount! {
            let itemCount = collectionView?.numberOfItems(inSection: track)
                        
            for item in 0..<itemCount! {
                let indexPath = IndexPath(item: item, section: track)
                let attributes = TimelineLayoutAttribute(forCellWith: indexPath)
                let width = delegate?.collectionView(collectionView: collectionView!, widthForItemAt: indexPath)
                let position = delegate?.collectionView(collectionView: collectionView!, positionForItemAt: indexPath)
                if position?.x ?? 0 > 0 {
                    xPos = position?.x
                }
                attributes.frame = CGRect(x: xPos ?? 0, y: yPos + (trackInsets?.top)!, width: width!, height: trackHeight! - (trackInsets?.bottom)!)
                /// 这个是transitionCell 的frame 计算
                if width == TRANSITION_CONTROL_HW {
                    var rect = attributes.frame
                    rect.origin.y += (rect.size.height - TRANSITION_CONTROL_HW) / 2 + VERTICAL_PADDING
                    rect.origin.x -= TRANSITION_CONTROL_HW / 2
                    attributes.frame = rect
                    attributes.zIndex = 1
                }
                if selectedIndexPath == indexPath {
                    attributes.isHidden = true
                }
                layoutDic[indexPath] = attributes
                if width != TRANSITION_CONTROL_HW {
                    xPos! += width! + clipSpacing!
                }
            }
            if xPos! > maxTrackWidth {
                maxTrackWidth = xPos!
            }
            xPos = trackInsets?.left
            yPos += trackHeight!
        }
        self.contentSize = CGSize(width: maxTrackWidth + (trackInsets?.right)!, height: CGFloat(trackCount!) * self.trackHeight!);
        caculateLayout = layoutDic

    }
    override var collectionViewContentSize: CGSize {
        get {
            self.contentSize!
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttribute = [UICollectionViewLayoutAttributes]()
        caculateLayout?.forEach({ (indexpath, element) in
            if rect.intersects(element.frame) {
                allAttribute.append(element)
            }
        })
        if let header = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) {
            allAttribute.append(header)
        }
        return allAttribute
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return caculateLayout?[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attribute: UICollectionViewLayoutAttributes?
        if super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) == nil {
            attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        }
        let x = (trackInsets?.left)!
        let y = CGFloat(0)
        let width = (contentSize?.width)! - (trackInsets?.left)! - (trackInsets?.right)!
        let height = (trackInsets?.top)!
        attribute?.frame = CGRect(x: x, y: y, width: width, height: height)
        return attribute
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        panGestureRecognize = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        longPressGestureRecognize = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognize?.minimumPressDuration = 0.5
        tapGestureRecognize = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tapGestureRecognize?.numberOfTapsRequired = 2
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        
        collectionView?.gestureRecognizers?.forEach({ (ges) in
            if ges.isKind(of: UIPanGestureRecognizer.self) {
                ges.require(toFail: panGestureRecognize!)
            } else if ges.isKind(of: UILongPressGestureRecognizer.self) {
                ges.require(toFail: longPressGestureRecognize!)
            }
        })
        
        panGestureRecognize?.delegate = self
        longPressGestureRecognize?.delegate = self
        tapGestureRecognize?.delegate = self
        pinchGestureRecognizer?.delegate = self
        
        collectionView?.addGestureRecognizer(pinchGestureRecognizer!)
        collectionView?.addGestureRecognizer(panGestureRecognize!)
        collectionView?.addGestureRecognizer(tapGestureRecognize!)
        collectionView?.addGestureRecognizer(longPressGestureRecognize!)
        
        panGestureRecognize?.isEnabled = false

    }
    
    @objc
    func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        if pinch.state == .began {
            collectionView?.isScrollEnabled = false
        } else if pinch.state == .changed {
            let scale = pinch.scale
            (self.collectionView?.delegate as! UICollectionViewDelegateTimelineLayout).collectionView(collectionView: collectionView!, changingScaleTo: scale)
        } else {
            collectionView?.isScrollEnabled = true
            let scale = pinch.scale
            (self.collectionView?.delegate as! UICollectionViewDelegateTimelineLayout).collectionView(collectionView: collectionView!, endScaleTo: scale)
        }
    }
    
    
    
    @objc
    func handleDrag(_ pan: UIPanGestureRecognizer) {
        let location = pan.location(in: collectionView)
        let transition = pan.translation(in: collectionView)
        panDirection = transition.x > 0 ? .right : .left

        guard let indexPath = collectionView?.indexPathForItem(at: location) else {return}
        let cell = collectionView?.cellForItem(at: indexPath) as? VideoItemCollectionViewCell
        if pan.state == .began {
            invalidateLayout()
        }
        if pan.state == .began || pan.state == .changed {
            if dragMode == .move {
                let centerPoint = dragableImageView?.center
                if selectedIndexPath?.section == 0 {
                    let center = CGPoint(x: (centerPoint?.x)! + transition.x, y: (centerPoint?.y)! + transition.y)
                    dragableImageView?.center = center
                    if swapInProgress == false {
                        swapClips()
                    }
                } else {
                    
                    let constrainedPoint = dragableImageView?.center
                    dragableImageView?.center =
                            CGPoint(x: constrainedPoint?.x ?? 0 + transition.x, y: constrainedPoint?.y ?? 0)
                    let xOrigin = (dragableImageView?.center.x)! - (dragableImageView?.frame.width)! / 2
                    let delegate: UICollectionViewDelegateTimelineLayout = collectionView?.delegate as! UICollectionViewDelegateTimelineLayout
                    let originPoint = CGPoint(x: xOrigin, y: 0)
                    delegate.collectionView(collectionView: collectionView!, didAdjustTo: originPoint, forItemAt: selectedIndexPath!)

                }
            } else {
                if indexPath.section != 0 {
                    return
                }
                let timeRange = cell!.maxTimeRagne
                scaleUnit = CGFloat(CMTimeGetSeconds(timeRange?.duration ?? .zero)) / cell!.frame.size.width
                let selectedIndexPaths = collectionView?.indexPathsForSelectedItems
                if selectedIndexPaths != nil && selectedIndexPaths?.count ?? 0 > 0 {
                    let selectedIndexPath = selectedIndexPaths?.first
                    if selectedIndexPath != nil {
                        guard let aCell = collectionView?.cellForItem(at: selectedIndexPath!) as? VideoItemCollectionViewCell else {return}
                        if aCell.isPointInDragHandle(point: collectionView?.convert(location, to: aCell) ?? .zero) {
                            self.trimming = true
                        }
                        if self.trimming == true {
                            let newFrameWidth = aCell.frame.width + transition.x
                            self.adjustToWidth(newFrameWidth)
                        }
                    }
                }
            }
            pan.setTranslation(.zero, in: collectionView)
        } else if pan.state == .ended || pan.state == .cancelled {
            trimming = false
        }
    }
    
    @objc
    func handleDoubleTap(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: collectionView)
        guard let indexPath = collectionView?.indexPathForItem(at: location) else { return }
        let delegate: UICollectionViewDelegateTimelineLayout = (collectionView?.delegate as! UICollectionViewDelegateTimelineLayout)
        delegate.collectionView(collectionView: collectionView!, willDeleteItemAt: indexPath)
        collectionView?.deleteItems(at: [indexPath])
    }
    
    @objc
    func handleLongPress(_ longPress: UITapGestureRecognizer) {
        if longPress.state == .began {
            dragMode = .move
            let location = longPress.location(in: collectionView)
            guard let indexPath = collectionView?.indexPathForItem(at: location) else {return}
            selectedIndexPath = indexPath
            collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            
            let cell = collectionView?.cellForItem(at: indexPath)
            cell?.isHighlighted = true
            dragableImageView = cell?.toImageView()
            dragableImageView?.frame = cell?.frame ?? .zero
            collectionView?.addSubview(dragableImageView!)
        }
        
        if longPress.state == .ended {
            let attributes = layoutAttributesForItem(at: selectedIndexPath!)
            UIView.animate(withDuration: 0.15, animations: {
                self.dragableImageView?.frame = (attributes?.frame)!
            }) { (result) in
                self.invalidateLayout()
                UIView.animate(withDuration: 0.2, animations: {
                    self.dragableImageView?.alpha = 0
                }) { (_) in
                    if self.selectedIndexPath != nil {
                        guard let cell = self.collectionView?.cellForItem(at: self.selectedIndexPath!) else {return}
                        cell.isSelected = true
                        self.dragableImageView?.removeFromSuperview()
                        self.dragableImageView = nil
                    }
                }
                self.selectedIndexPath = nil
                self.dragMode = .trim
            }
        }
    }
    
    func swapClips() {

        let center = dragableImageView?.center
        guard let indexPath = collectionView?.indexPathForItem(at: center!) else {return}
        guard let delegate = collectionView?.delegate as? UICollectionViewDelegateTimelineLayout else {return}
        
        if shouldSwapSelectedIndexPath(selected: selectedIndexPath!, with: indexPath) {
            if !delegate.collectionView(collectionView: collectionView!, canMoveItemAt: indexPath) {
                return
            }
            swapInProgress = true
            let lastSelectedIndexPath = selectedIndexPath!
            selectedIndexPath = indexPath
            delegate.collectionView(collectionView: collectionView!, didMoveMediaItemAt: lastSelectedIndexPath, toIndexPath: selectedIndexPath!)
            collectionView?.performBatchUpdates({
                                                    collectionView?.deleteItems(at: [lastSelectedIndexPath])
                                                    collectionView?.insertItems(at: [selectedIndexPath!])
                                                }, completion: { result in
                self.swapInProgress = false
                self.invalidateLayout()
                                                })

        }
    }

    func shouldSwapSelectedIndexPath(selected: IndexPath, with hover: IndexPath) -> Bool {
        if panDirection == .right {
            return selected.row < hover.row
        } else {
            return selected.row > hover.row
        }
    }

    func adjustToWidth(_ width: CGFloat) {
        let delegate: UICollectionViewDelegateTimelineLayout = collectionView?.delegate as! UICollectionViewDelegateTimelineLayout
        let indexPath = (collectionView?.indexPathsForSelectedItems?.first)!
        delegate.collectionView(collectionView: collectionView!, didAdjustTo: width, forItemAt: indexPath)
        invalidateLayout()
    }
    
}


class TimelineLayoutAttribute: UICollectionViewLayoutAttributes {
    var maxFrameWidth: CGFloat?
    var scaleUnit: CGFloat?
    
}



extension TimelineLayout: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
