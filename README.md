# hockeyapp-crash-data
Get some crash stats from HockeyApp, grouped by user, using the [Crash API](https://support.hockeyapp.net/kb/api/api-crashes).


# Debug Build

**Use Xcode**, or, from comand line:
1. Build with `swift build`
2. Help with `swift run hockeyapp-crash-data --help`
3. Run with `swift run hockeyapp-crash-data HOCKEYAPP_TOKEN HOCKEYAPP_APPID OUTPUT_FILE` to run


# Release

1. Build with `swift build -c release -Xswiftc -static-stdlib` (\*)
2. Install with `cp .build/release/hockeyapp-crash-data` `/use/local/bin/`
3. Help with `hockeyapp-crash-data --help`
4. Run with `hockeyapp-crash-data HOCKEYAPP_TOKEN HOCKEYAPP_APPID OUTPUT_FILE`

  (\*): statically link the Swift standard library, so that the command line tool is not bound to the specific version of Swift that it was built with.


# Development

- **build**: `swift build`
- **run**: `swift run`
- **update dependencies**: edit `Package.swift` then type `./update.deps.sh`