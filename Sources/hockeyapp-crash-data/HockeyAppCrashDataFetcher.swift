//
//  HockeyAppCrashDataFetcher.swift
//  Commander
//
//  Created by Nuno Grilo on 29/01/2019.
//

import Foundation

public final class HockeyAppCrashDataFetcher {
    private var token: String
    private var appID: String
    
    init(token: String, appID: String) {
        self.token = token
        self.appID = appID
    }
    
    func fetchCrashDataPerUser() {
        print("fetchCrashDataPerUser()...")
    }
}
