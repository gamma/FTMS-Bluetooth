import XCTest
@testable import FTMS_Bluetooth

final class FTMS_BluetoothTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FTMS_Bluetooth().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
