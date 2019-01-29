import Foundation
import Commander

// fetch crash data
let fetchCommand = command(
    Argument<String>("token", description: "The HockeyApp Token")
    ) { token in
        HockeyAppCrashDataFetcher(token: token).fetchCrashDataPerUser()
    }
fetchCommand.run()
