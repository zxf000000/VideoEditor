//
//  TimelineItemViewModel.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import CoreMedia

class TimelineItemViewModel {
    var widthInTimeline: CGFloat? {
        get {
            return GetWidthFor(timeRange: (timelineItem?.timeRange)!, scaleFactor: TIMELINE_SINGLESECOND_WIDTH * (timelineItem?.scale)!)
        }
    }
    var maxWidthInTimeline: CGFloat?
    var positionInTimeline: CGPoint?
    
    var timelineItem: TimeLineItem?
    
    init(timeline: TimeLineItem) {
        self.timelineItem = timeline
        let maxTimeRange = CMTimeRangeMake(start: .zero, duration: timelineItem?.timeRange?.duration ?? .zero)
        maxWidthInTimeline = GetWidthFor(timeRange: maxTimeRange, scaleFactor: TIMELINE_SINGLESECOND_WIDTH * (timelineItem?.scale)!)
    }
    func udpateTimelineItem() {
        if positionInTimeline?.x ?? 0 > 0 {
            let startTime = GetTime(for: positionInTimeline?.x ?? 0, scaleFactor: TIMELINE_SINGLESECOND_WIDTH * (timelineItem?.scale)!)
            timelineItem?.startTimeInTimeLine = startTime
        }
        timelineItem?.timeRange = GetTimeRange(for: widthInTimeline!, scaleFactor: TIMELINE_SINGLESECOND_WIDTH * (timelineItem?.scale)!)
    }
}
