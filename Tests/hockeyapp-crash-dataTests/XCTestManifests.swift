import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(hockeyapp_crash_dataTests.allTests),
    ]
}
#endif