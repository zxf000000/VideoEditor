//
//  PlaybackMediator.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation

protocol PlaybackMediator {
    func loadMediaItem(item: MediaItem)
    func previewMediaItem(item: MediaItem)
    func addMediaItem(item: MediaItem, toTimelineTrack: MediaTrackType)
    func prepareTimelineForPlayback()
    func stopPlayback()
}
