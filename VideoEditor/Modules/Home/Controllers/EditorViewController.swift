//
//  EditorViewController.swift
//  VideoEditor
//
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit
import AVFoundation

let EXPORTING_KEYPATH =       "exporting"
let PROGRESS_KEYPATH  =       "progress"

class EditorViewController: UIViewController {
    
    
    var timelineVC: TimeLineViewController!
    var playerVC: PlayerViewController!
    var factory: CompositionBuilderFactory! = CompositionBuilderFactory()
    var exporter: CompositionExporter!
    
    var assets: [AVAsset]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timelineheight = (view.bounds.size.height - NavigationStatusBarHeight - BottomSafeAreaHeight) / 2
        
        timelineVC = R.storyboard.main.timeLineViewController()
         view.addSubview(timelineVC!.view)
         addChild(timelineVC!)
         
         
        playerVC = R.storyboard.main.playerViewController()
        addChild(playerVC!)
        view.addSubview(playerVC!.view)
         
        playerVC.view.frame = CGRect(x: 0, y: NavigationStatusBarHeight, width: view.bounds.width, height: timelineheight)
        
        timelineVC.view.frame = CGRect(x: 0, y: playerVC.view.frame.maxY, width: view.bounds.size.width, height: timelineheight)

        NotificationCenter.default.addObserver(self,
                                                selector: #selector(exportComposition(notification:)),
                                                name: ExportRequestedNotification,
                                                object: nil)
        
        if assets.count > 0 {
            var videoItem: VideoItem?
            for asset in assets {
                videoItem = VideoItem(url: (asset as! AVURLAsset).url)
                addMediaItem(item: videoItem!, toTimelineTrack: .video)
            }
        }
        
    }
    
    @objc
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension EditorViewController: PlaybackMediator {
    func loadMediaItem(item: MediaItem) {
        
    }
    func previewMediaItem(item: MediaItem) {
        
    }
    func addMediaItem(item: MediaItem, toTimelineTrack: MediaTrackType) {
        timelineVC.addTimelineItem(item: item, to: toTimelineTrack)
    }
    func prepareTimelineForPlayback() {
        let timeline = timelineVC.currentTimeLine()
        let builder = factory.builder(for: timeline)
        let composition = builder?.buildComposition()
        guard let playerItem = composition?.makePlayable() else {return}
        timelineVC.synchronizePlayHead(with: playerItem)
        playerVC.play(item: playerItem)
    }
    func stopPlayback() {
        playerVC.stopPlayback()
    }
    @objc
    func exportComposition(notification: Notification) {
        let timeline = timelineVC.currentTimeLine()
        let builder = factory.builder(for: timeline)
        guard let composition = builder?.buildComposition() else {return}
        let exporter = CompositionExporter(compositon: composition)
        exporter.addObserver(self, forKeyPath: EXPORTING_KEYPATH, options: .new, context: nil)
        exporter.addObserver(self, forKeyPath: PROGRESS_KEYPATH, options: .new, context: nil)
        exporter.beginExport()
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == EXPORTING_KEYPATH {
            guard let exporting = change?[NSKeyValueChangeKey.newKey] as? Bool else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            playerVC.exporting = exporting
            if exporting == false {
                exporter.removeObserver(self, forKeyPath: EXPORTING_KEYPATH)
                exporter.removeObserver(self, forKeyPath: PROGRESS_KEYPATH)
            }
        } else if keyPath == PROGRESS_KEYPATH {
            guard let progress = change?[NSKeyValueChangeKey.newKey] as? CGFloat else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            playerVC.progressView.progress = Float(progress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
