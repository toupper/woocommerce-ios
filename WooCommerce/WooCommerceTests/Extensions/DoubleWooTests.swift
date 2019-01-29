import XCTest
@testable import WooCommerce


/// Double+Woo: Unit Tests
///
class DoubleWooTests: XCTestCase {

    func testHumanReadableStringWorksWithZeroValue() {
        XCTAssertEqual(Double(0).humanReadableString(), "0")
        XCTAssertEqual(Double(-0).humanReadableString(), "0")
        XCTAssertEqual(Double(0.01).humanReadableString(), "0")
        XCTAssertEqual(Double(-0.01).humanReadableString(), "0")
    }

    func testHumanReadableStringWorksWithPositiveValuesUnderOneThousand() {
        XCTAssertEqual(Double(1).humanReadableString(), "1")
        XCTAssertEqual(Double(10).humanReadableString(), "10")
        XCTAssertEqual(Double(198).humanReadableString(), "198")
        XCTAssertEqual(Double(198.44).humanReadableString(), "198")
        XCTAssertEqual(Double(198.44).humanReadableString(), "198")
        XCTAssertEqual(Double(199.99).humanReadableString(), "199")
        XCTAssertEqual(Double(999).humanReadableString(), "999")
        XCTAssertEqual(Double(999.99).humanReadableString(), "999")
        XCTAssertEqual(Double(999.99999).humanReadableString(), "999")
        XCTAssertEqual(Double(1000).humanReadableString(), "1.0k")
        XCTAssertEqual(Double(1000.00001).humanReadableString(), "1.0k")
    }

    func testHumanReadableStringWorksWithNegativeValuesUnderOneThousand() {
        XCTAssertEqual(Double(-1).humanReadableString(), "-1")
        XCTAssertEqual(Double(-10).humanReadableString(), "-10")
        XCTAssertEqual(Double(-198.44).humanReadableString(), "-198")
        XCTAssertEqual(Double(-199).humanReadableString(), "-199")
        XCTAssertEqual(Double(-199.99).humanReadableString(), "-199")
        XCTAssertEqual(Double(-999).humanReadableString(), "-999")
        XCTAssertEqual(Double(-999.99).humanReadableString(), "-999")
        XCTAssertEqual(Double(-999.99999).humanReadableString(), "-999")
        XCTAssertEqual(Double(-1000).humanReadableString(), "-1.0k")
        XCTAssertEqual(Double(-1000.00001).humanReadableString(), "-1.0k")
    }

    func testHumanReadableStringWorksWithPositiveValuesAboveOneThousand() {
        XCTAssertEqual(Double(1000).humanReadableString(), "1.0k")
        XCTAssertEqual(Double(1000.00001).humanReadableString(), "1.0k")
        XCTAssertEqual(Double(999999).humanReadableString(), "1.0m")
        XCTAssertEqual(Double(1000000).humanReadableString(), "1.0m")
        XCTAssertEqual(Double(1000000.00001).humanReadableString(), "1.0m")
        XCTAssertEqual(Double(999999999).humanReadableString(), "1.0b")
        XCTAssertEqual(Double(1000000000).humanReadableString(), "1.0b")
        XCTAssertEqual(Double(1000000000.00001).humanReadableString(), "1.0b")
        XCTAssertEqual(Double(999999999999).humanReadableString(), "1.0t")
        XCTAssertEqual(Double(1000000000000).humanReadableString(), "1.0t")
        XCTAssertEqual(Double(1000000000000.00001).humanReadableString(), "1.0t")

        XCTAssertEqual(Double(9880).humanReadableString(), "9.9k")
        XCTAssertEqual(Double(9999).humanReadableString(), "10.0k")
        XCTAssertEqual(Double(44999).humanReadableString(), "45.0k")
        XCTAssertEqual(Double(77164).humanReadableString(), "77.2k")
        XCTAssertEqual(Double(100101).humanReadableString(), "100.1k")
        XCTAssertEqual(Double(110099).humanReadableString(), "110.1k")
        XCTAssertEqual(Double(9899999).humanReadableString(), "9.9m")
        XCTAssertEqual(Double(5800199).humanReadableString(), "5.8m")
        XCTAssertEqual(Double(998999999).humanReadableString(), "999.0m")
    }

    func testHumanReadableStringWorksWithNegativeValuesAboveOneThousand() {
        XCTAssertEqual(Double(-1000).humanReadableString(), "-1.0k")
        XCTAssertEqual(Double(-1000.00001).humanReadableString(), "-1.0k")
        XCTAssertEqual(Double(-999999).humanReadableString(), "-1.0m")
        XCTAssertEqual(Double(-1000000).humanReadableString(), "-1.0m")
        XCTAssertEqual(Double(-1000000.00001).humanReadableString(), "-1.0m")
        XCTAssertEqual(Double(-999999999).humanReadableString(), "-1.0b")
        XCTAssertEqual(Double(-1000000000).humanReadableString(), "-1.0b")
        XCTAssertEqual(Double(-1000000000.00001).humanReadableString(), "-1.0b")
        XCTAssertEqual(Double(-999999999999).humanReadableString(), "-1.0t")
        XCTAssertEqual(Double(-1000000000000).humanReadableString(), "-1.0t")
        XCTAssertEqual(Double(-1000000000000.00001).humanReadableString(), "-1.0t")

        XCTAssertEqual(Double(-9880).humanReadableString(), "-9.9k")
        XCTAssertEqual(Double(-9999).humanReadableString(), "-10.0k")
        XCTAssertEqual(Double(-44999).humanReadableString(), "-45.0k")
        XCTAssertEqual(Double(-77164).humanReadableString(), "-77.2k")
        XCTAssertEqual(Double(-100101).humanReadableString(), "-100.1k")
        XCTAssertEqual(Double(-110099).humanReadableString(), "-110.1k")
        XCTAssertEqual(Double(-9899999).humanReadableString(), "-9.9m")
        XCTAssertEqual(Double(-5800199).humanReadableString(), "-5.8m")
        XCTAssertEqual(Double(-998999999).humanReadableString(), "-999.0m")
    }
}
