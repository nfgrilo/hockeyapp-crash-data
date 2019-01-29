//
//  UserStats.swift
//  hockeyapp-crash-data
//
//  Created by Nuno Grilo on 29/01/2019.
//

import Foundation

class UserStats: CustomStringConvertible {
    let user: String
    
    var totalCrashes: Int = 0
    var crashesPerReason: [Int: Int] = [:]
    
    init(user: String) {
        self.user = user
    }
    
    var description: String {
        return "User \(user) -> #\(totalCrashes) crashes [crashesPerReason: \(crashesPerReason)]"
    }
}
