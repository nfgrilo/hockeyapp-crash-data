import Foundation
import Commander

Group {
    
    // Total crashes per user
    let userCrashesCommand = command(
        Argument<String>("token", description: "The HockeyApp Token"),
        Argument<String>("appID", description: "The unique identifier for the HockeyApp application"),
        Argument<String>("file", description: "Output CSV file")
    ) { token, appID, file in
        let api = HockeyAppAPI(token: token, appID: appID)
        HockeyAppCrashDataFetcher(api: api).fetchCrashDataPerUser(export: .userCrashes, to: file) {
            exit(EXIT_SUCCESS)
        }
        RunLoop.main.run()
    }
    $0.addCommand("user-crashes", "Fetch and exports total crashes per user", userCrashesCommand)
    
    // Total crash groups per user
    let userCrashGroupStatsCommand = command(
        Argument<String>("token", description: "The HockeyApp Token"),
        Argument<String>("appID", description: "The unique identifier for the HockeyApp application"),
        Argument<String>("file", description: "Output CSV file")
    ) { token, appID, file in
        let api = HockeyAppAPI(token: token, appID: appID)
        HockeyAppCrashDataFetcher(api: api).fetchCrashDataPerUser(export: .userCrashGroupStats, to: file) {
            exit(EXIT_SUCCESS)
        }
        RunLoop.main.run()
    }
    $0.addCommand("user-crash-groups", "Fetch and exports total crashes groups per user", userCrashGroupStatsCommand)
    
}.run()
