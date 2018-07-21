import XCTest
@testable import PaversFRP

final class PaversFRPTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(PaversFRP().text, "Hello, World!")
//      let ones = infiniteOne()
//      for _ in 1 ... 10 {
//        let h = head(xs: ones)
//        print(h)
//      }
      
      var fibs = fib()
      for _ in 1 ... 10 {
        let h = head(xs: fibs)
        fibs = tail(xs: {fibs})()
        print(h)
      }
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
