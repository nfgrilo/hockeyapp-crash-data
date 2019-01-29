//
//  Throttler.swift
//  hockeyapp-crash-data
//
//  Created by Nuno Grilo on 29/01/2019.
//

import Foundation
import Jobs

class Throttler {
    
    private var maxInterval: Int
    private var nextRun: Date?
    private var previousRun: Date = Date.distantPast
    
    init(seconds: Int) {
        self.maxInterval = seconds
    }

    func throttle(block: @escaping () -> Void) {
        var delay: TimeInterval = 0
        if let nextRun = self.nextRun {
            delay = Date.second(from: previousRun) > TimeInterval(maxInterval) ? 0 : TimeInterval(maxInterval)
            self.nextRun = delay == 0 ? Date() : nextRun.addingTimeInterval(delay)
            delay += Date.second(since: nextRun)
        } else {
            nextRun = Date()
        }

        Jobs.oneoff(delay: delay.seconds) { [weak self] in
            //print("Executing at \(Date())")
            self?.previousRun = Date()
            block()
        }
    }
    
}

private extension Date {
    static func second(from referenceDate: Date) -> TimeInterval {
        return Date().timeIntervalSince(referenceDate)
    }
    static func second(since referenceDate: Date) -> TimeInterval {
        return -Date().timeIntervalSince(referenceDate)
    }
}
