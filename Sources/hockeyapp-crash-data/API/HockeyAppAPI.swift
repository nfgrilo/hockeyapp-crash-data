//
//  HockeyAppAPI.swift
//  hockeyapp-crash-data
//
//  Created by Nuno Grilo on 29/01/2019.
//

import Foundation

class HockeyAppAPI {
    private var token: String
    private var appID: String
    private var baseURLString = "https://rink.hockeyapp.net"
    private var isDebug: Bool = false
    
    // Rate Limiting:
    // > We limit requests to 60 per minute and App ID. If the limit is exceeded, please throttle your scripts.
    // >> So, let's use 50 per minute to be safe.
    private var rateLimitPerMinute: Int = 50
    private lazy var throttler: Throttler = {
        return Throttler(seconds: 60/rateLimitPerMinute)
    }()
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpMaximumConnectionsPerHost = 5
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    init(token: String, appID: String, rateLimitPerMinute: Int? = nil) {
        self.token = token
        self.appID = appID
        if let rateLimit = rateLimitPerMinute {
            self.rateLimitPerMinute = rateLimit
        }
    }
    
    
    // MARK: Crash Groups
    
    func listAllCrashReasons(completion: @escaping ([CrashGroup]) -> Void) {
        // get first page
        listCrashGroups(page: 1) { [weak self] crashGroupsResponse in
            guard
                let self = self,
                let response = crashGroupsResponse else {
                completion([])
                return
            }
            let totalPages = self.isDebug ? 2 : response.totalPages
            if totalPages > 1 {
                print("Fetching all \(totalPages) crash reasons pages...")
            }

            // fetch all crash reason IDs
            var crashGroupIDs: [Int] = response.crashReasons.map { $0.id }
            let dispatchGroup = DispatchGroup()
            
            for page in 2..<(totalPages+1) {
                dispatchGroup.enter()
                self.listCrashGroups(page: page, completion: { r in
                    guard let r = r else {
                        dispatchGroup.leave()
                        return
                    }
                    crashGroupIDs.append(contentsOf: r.crashReasons.map { $0.id })
                    dispatchGroup.leave()
                })
            }
            
            // done fetching all crash reason IDs
            dispatchGroup.notify(queue: .main) {
                print("Finished fetching crash reasons.")
                
                let totalCrashGroups = self.isDebug ? 2 : crashGroupIDs.count
                print("Fetching all \(totalCrashGroups) individual crash reasons...")
                
                // -> fetch each crash reason
                var crashGroups: [CrashGroup] = []
                let dispatchGroup2 = DispatchGroup()
                for id in crashGroupIDs[..<totalCrashGroups] {
                    dispatchGroup2.enter()
                    self.crashGroup(reasonId: id) { crashGroup in
                        if let group = crashGroup {
                            crashGroups.append(group)
                        }
                        dispatchGroup2.leave()
                    }
                }
                dispatchGroup2.notify(queue: .main) {
                    // done
                    print("Finished fetching crashes.")
                    completion(crashGroups)
                }
            }
            
        }
        
    }
    
    private func listCrashGroups(page: Int, completion: @escaping (CrashGroupsResponse?) -> Void) {
        // GET /api/2/apps/APP_ID/crash_reasons
        guard let url = URL(string: "\(baseURLString)/api/2/apps/\(appID)/crash_reasons?page=\(page)&per_page=100") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-HockeyAppToken")
        
        throttler.throttle { [weak self] in
            print("Fetching crash reasons for page \(page)...")
            let task = self?.session.dataTask(with: request) { (data, response, error) in
                guard let dataResponse = data, error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601HockeyAppAPI)
                    let response = try decoder.decode(CrashGroupsResponse.self, from: dataResponse)
                    completion(response)
                } catch {
                    print("Error: \(error)")
                    completion(nil)
                }
            }
            task?.resume()
        }
    }
    
    private func crashGroup(reasonId: Int, completion: @escaping (CrashGroup?) -> Void) {
        // fetch 1st page of a group's crashes
        crashGroup(reasonId: reasonId, page: 1) { [weak self] response in
            guard let response = response else {
                completion(nil)
                return
            }
            
            var crashes: [CrashGroupResponse.Crash] = []
            
            // add page 1 crashes
            crashes.append(contentsOf: response.crashes)
            
            // fetch remaming crash pages
            let dispatchGroup = DispatchGroup()
            for page in 2..<(response.totalPages+1) {
                dispatchGroup.enter()
                self?.crashGroup(reasonId: reasonId, page: page) { response2 in
                    guard let response2 = response2 else {
                        dispatchGroup.leave()
                        return
                    }
                    // add remaining crash pages
                    crashes.append(contentsOf: response2.crashes)
                    dispatchGroup.leave()
                }
            }
            
            // done
            dispatchGroup.notify(queue: .main) {
                completion(CrashGroup(crashReason: response.crashReason, crashes: crashes))
            }
        }
    }
    
    private func crashGroup(reasonId: Int, page: Int, completion: @escaping (CrashGroupResponse?) -> Void) {
        // GET /api/2/apps/APP_ID/crash_reasons/REASON_ID
        guard let url = URL(string: "\(baseURLString)/api/2/apps/\(appID)/crash_reasons/\(reasonId)?page=\(page)&per_page=100") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-HockeyAppToken")
        
        throttler.throttle { [weak self] in
            print("Fetching crashes for crash reason \(reasonId)...")
            let task = self?.session.dataTask(with: request) { (data, response, error) in
                guard let dataResponse = data, error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601HockeyAppAPI)
                    let response = try decoder.decode(CrashGroupResponse.self, from: dataResponse)
                    completion(response)
                } catch {
                    print("Error: \(error)")
                    completion(nil)
                }
            }
            task?.resume()
        }
    }
    
}
