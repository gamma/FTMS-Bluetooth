import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FTMS_BluetoothTests.allTests),
    ]
}
#endif
