# hockeyapp-crash-data

Get some crash stats from HockeyApp, grouped by user, using the [Crash API](https://support.hockeyapp.net/kb/api/api-crashes).

![Help](https://raw.githubusercontent.com/nfgrilo/hockeyapp-crash-data/master/Images/screenshot-1.png)
![Commands Help](https://raw.githubusercontent.com/nfgrilo/hockeyapp-crash-data/master/Images/screenshot-2.png)

# Release Build

From **command line:**

- **Build** with `swift build -c release -Xswiftc -static-stdlib` (\*)
- **Install** with `cp .build/release/hockeyapp-crash-data /usr/local/bin/`
- **Get help** with `hockeyapp-crash-data --help`.
- **Get commands help** with `hockeyapp-crash-data COMMAND --help`.
- **Run** with `hockeyapp-crash-data [user-crashes|user-crash-groups] HOCKEYAPP_TOKEN HOCKEYAPP_APPID OUTPUT_FILE`

  (\*): statically link the Swift standard library, so that the command line tool is not bound to the specific version of Swift that it was built with.


# Development

**a) Use Xcode**, or, 

**b) Command line:**

- **Build** with `swift build`
- **Get help** with `swift run hockeyapp-crash-data --help`.
- **Get commands help** with `swift run hockeyapp-crash-data COMMAND --help`.
- **Run** with `swift run hockeyapp-crash-data HOCKEYAPP_TOKEN HOCKEYAPP_APPID OUTPUT_FILE`

**PS**: After modifying dependencies on `Package.swift`, type `./update.deps.sh`