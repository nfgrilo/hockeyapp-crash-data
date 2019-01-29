//
//  CrashGroup.swift
//  hockeyapp-crash-data
//
//  Created by Nuno Grilo on 29/01/2019.
//

import Foundation

struct CrashGroup: Codable {
    let crashReason: CrashGroupResponse.CrashReason
    let crashes: [CrashGroupResponse.Crash]
}
