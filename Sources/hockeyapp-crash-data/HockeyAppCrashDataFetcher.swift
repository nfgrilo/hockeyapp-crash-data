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
    
    enum ExportType {
        case userCrashes
        case userCrashGroupStats
    }
    
    func fetchCrashDataPerUser(export exportType: ExportType, to filename: String, completion: @escaping () -> Void) {
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
            print("Total Crash Groups = \(crashGroups.count)")
            print("Total Crashes = \(crashGroups.reduce(0, { $0 + $1.crashes.count }))")
            print("Total Users = \(stats.keys.count)")
            print("##############################################")
            
            // export to file
            if !filename.isEmpty {
                switch exportType {
                case .userCrashes:
                    self.exportUserCrashesToCSV(filename, stats: stats)
                case .userCrashGroupStats:
                    self.exportUserCrashGroupStatsToCSV(filename, stats: stats)
                }
            } else {
                print("No file to export to was specified.")
            }
            
            print("##############################################")
            
            completion()
        }
    }
    
    private func exportUserCrashGroupStatsToCSV(_ filename: String, stats: [String: UserStats]) {
        // prepare string
        var csv = "\"User ID\",\"Crash Reason ID\",\"Total Reason Crashes\"\r\n"
        stats.values.forEach { userStats in
            userStats.crashesPerReason.forEach { reasonID, reasonCrashCount in
                csv += "\"\(userStats.user)\",\(reasonID),\(reasonCrashCount)\r\n"
            }
        }
        
        // save
        let fileURL = URL(fileURLWithPath: filename)
        do {
            try csv.write(to: fileURL, atomically: false, encoding: .utf8)
            print("Data was exported to \(filename)")
        } catch {
            print("Failed to export data to \(filename): \(error)")
        }
    }
    
    private func exportUserCrashesToCSV(_ filename: String, stats: [String: UserStats]) {
        // prepare string
        var csv = "\"User ID\",\"Total Crashes\"\r\n"
        stats.values.forEach { userStats in
            userStats.crashesPerReason.forEach { reasonID, reasonCrashCount in
                csv += "\"\(userStats.user)\",\(userStats.totalCrashes)\r\n"
            }
        }
        
        // save
        let fileURL = URL(fileURLWithPath: filename)
        do {
            try csv.write(to: fileURL, atomically: false, encoding: .utf8)
            print("Data was exported to \(filename)")
        } catch {
            print("Failed to export data to \(filename): \(error)")
        }
    }
    
}
