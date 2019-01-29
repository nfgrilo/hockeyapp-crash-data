//
//  CrashGroupsResponse.swift
//  hockeyapp-crash-data
//
//  Created by Nuno Grilo on 29/01/2019.
//

import Foundation


struct CrashGroupsResponse: Codable {
    struct CrashReason: Codable {
        let id: Int
        let appId: Int
        let appVersionId: Int
        let numberOfCrashes: Int
        let createdAt: Date
        let updatedAt: Date
        let lastCrashAt: Date
        let bundleShortVersion: String?
        let bundleVersion: String?
        let status: Int
        let fixed: Bool?
        let file: String?
        let `class`: String?
        let method: String?
        let line: String?
        let reason: String?
    }
    
    let crashReasons: [CrashReason]
    
    let totalEntries: Int
    let totalPages: Int
    let perPage: Int
    let status: String
    let currentPage: Int
}


struct CrashGroupResponse: Codable {
    typealias CrashReason = CrashGroupsResponse.CrashReason
    
    struct Crash: Codable {
        let id: Int
        let appId: Int
        let appVersionId: Int
        let crashReasonId: Int
        let createdAt: Date
        let updatedAt: Date
        let oem: String
        let model: String
        let bundleVersion: String
        let bundleShortVersion: String
        let contactString: String
        let userString: String
        let osVersion: String
        let jailBreak: Bool
    }
    
    let crashReason: CrashReason
    let crashes: [Crash]
    
    let totalEntries: Int
    let totalPages: Int
    let perPage: Int
    let status: String
    let currentPage: Int
}

extension DateFormatter {
    static let iso8601HockeyAppAPI: DateFormatter = {
        let formatter = DateFormatter()
        //2011-10-18T16:59:03Z
        //formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
