import Foundation
import Commander

// fetch crash data
let fetchCommand = command(
    Argument<String>("token", description: "The HockeyApp Token"),
    Argument<String>("appID", description: "The unique identifier for the HockeyApp application"),
    Argument<String>("file", description: "Output CSV file")
    ) { token, appID, file in
        let api = HockeyAppAPI(token: token, appID: appID)
        HockeyAppCrashDataFetcher(api: api).fetchCrashDataPerUser(exportTo: file) {
            exit(EXIT_SUCCESS)
        }
        RunLoop.main.run()
    }
fetchCommand.run()
