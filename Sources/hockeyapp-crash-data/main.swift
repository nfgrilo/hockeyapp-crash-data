import Foundation
import Commander

// fetch crash data
let fetchCommand = command(
    Argument<String>("token", description: "The HockeyApp Token"),
    Argument<String>("appID", description: "The unique identifier for the HockeyApp application")
    ) { token, appID in
        HockeyAppCrashDataFetcher(token: token, appID: appID).fetchCrashDataPerUser()
    }
fetchCommand.run()
