//
//  HockeyAppCrashDataFetcher.swift
//  Commander
//
//  Created by Nuno Grilo on 29/01/2019.
//

import Foundation

public final class HockeyAppCrashDataFetcher {
    private var api: HockeyAppAPI
    
    init(api: HockeyAppAPI) {
        self.api = api
    }
    
    
    // MARK: Crash Data
    
    func fetchCrashDataPerUser(exportTo filename: String, completion: @escaping () -> Void) {
        api.listAllCrashReasons() { crashGroups in
            var stats: [String: UserStats] = [:]
            
            // update stats for user
            func updateUserStats(_ user: String, reasonId: Int, reasonCrashes: Int) {
                var newStats: UserStats!
                
                if let existing = stats[user] {
                    existing.totalCrashes += reasonCrashes
                    if let existingReasonCrashes = existing.crashesPerReason[reasonId] {
                        existing.crashesPerReason[reasonId] = existingReasonCrashes + reasonCrashes
                    } else {
                        existing.crashesPerReason[reasonId] = reasonCrashes
                    }
                    newStats = existing
                } else {
                    let userStats = UserStats(user: user)
                    userStats.totalCrashes = reasonCrashes
                    userStats.crashesPerReason[reasonId] = reasonCrashes
                    newStats = userStats
                }
                
                stats[user] = newStats
            }
            
            // iterate crash groups
            crashGroups.forEach { crashGroup in
                let reason = crashGroup.crashReason
                // and crashes
                crashGroup.crashes.forEach { crash in
                    guard !crash.userString.isEmpty else { return }
                    updateUserStats(crash.userString, reasonId: reason.id, reasonCrashes: 1)
                }
            }
            
            // present results
            print("##############################################")
            print("Crash Groups: count=\(crashGroups.count), total crashes=\(crashGroups.reduce(0, { $0 + $1.crashes.count }))")
            print("# Crash groups = \(crashGroups.count)")
            print("# Crashes = \(crashGroups.reduce(0, { $0 + $1.crashes.count }))")
            print("# Users = \(stats.keys.count)")
            print("##############################################")
            
            // export to file
            if !filename.isEmpty {
                // prepare string
                var csv = "UserID,CrashReasonID,ReasonCrashes,TotalCrashes\r\n"
                stats.values.forEach { userStats in
                    userStats.crashesPerReason.forEach { reasonID, reasonCrashCount in
                        csv += "\"\(userStats.user)\",\(reasonID),\(reasonCrashCount),\(userStats.totalCrashes)\r\n"
                    }
                }
                
                let fileURL = URL(fileURLWithPath: filename)
                do {
                    try csv.write(to: fileURL, atomically: false, encoding: .utf8)
                }
                catch {
                    print("Failed to export data to \(filename): \(error)")
                }
                print("Data was exported to \(filename)")
            } else {
                print("No file argument was specified => data was now exported")
            }
            print("##############################################")
            
            completion()
        }
    }
    
}
