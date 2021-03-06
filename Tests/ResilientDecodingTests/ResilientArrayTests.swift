// Created by George Leontiev on 3/31/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import ResilientDecoding
import XCTest

private struct ResilientArrayWrapper: Decodable {
  @Resilient var resilientArray: [Int]
  @Resilient var optionalResilientArray: [Int]?
}

final class ResilientArrayTests: XCTestCase {

  func testDecodesValidInputWithoutErrors() throws {
    let mock = try decodeMock(ResilientArrayWrapper.self, """
      {
        "resilientArray": [1, 2, 3],
        "optionalResilientArray": [4, 5, 6],
      }
      """)
    XCTAssertEqual(mock.resilientArray, [1, 2, 3])
    XCTAssertEqual(mock.optionalResilientArray, [4, 5, 6])
    XCTAssert(mock.$resilientArray.errors.isEmpty)
    XCTAssert(mock.$optionalResilientArray.errors.isEmpty)
  }

  func testDecodesWhenMissingKeys() throws {
    let mock = try decodeMock(ResilientArrayWrapper.self, """
      {
      }
      """)
    XCTAssertEqual(mock.resilientArray, [])
    XCTAssertNil(mock.optionalResilientArray)
    XCTAssertEqual(mock.$resilientArray.errors.count, 0)
    XCTAssertEqual(mock.$optionalResilientArray.errors.count, 0)
  }

  func testDecodesNullValue() throws {
    let mock = try decodeMock(ResilientArrayWrapper.self, """
      {
        "resilientArray": null,
        "optionalResilientArray": null,
      }
      """)
    XCTAssertEqual(mock.resilientArray, [])
    XCTAssertNil(mock.optionalResilientArray)
    XCTAssertEqual(mock.$resilientArray.errors.count, 0)
    XCTAssertEqual(mock.$optionalResilientArray.errors.count, 0)
  }

  func testResilientlyDecodesIncorrectType() throws {
    let mock = try decodeMock(ResilientArrayWrapper.self, """
      {
        "resilientArray": 1,
        "optionalResilientArray": 1,
      }
      """,
      expectedErrorCount: 2)
    XCTAssertEqual(mock.resilientArray, [])
    XCTAssertEqual(mock.$resilientArray.errors.count, 1)
    XCTAssertEqual(mock.$resilientArray.results.map { try? $0.get() }, [nil])
    XCTAssertEqual(mock.optionalResilientArray, [])
    XCTAssertEqual(mock.$optionalResilientArray.errors.count, 1)
    XCTAssertEqual(mock.$optionalResilientArray.results.map { try? $0.get() }, [nil])
  }

  func testResilientlyDecodesArratWithInvalidElements() throws {
    let mock = try decodeMock(ResilientArrayWrapper.self, """
      {
        "resilientArray": [1, "2", 3, "4", 5],
        "optionalResilientArray": ["1", 2, "3", "4", 5],
      }
      """,
      expectedErrorCount: 5)
    XCTAssertEqual(mock.resilientArray, [1, 3, 5])
    XCTAssertEqual(mock.$resilientArray.errors.count, 2)
    XCTAssertEqual(mock.$resilientArray.results.map { try? $0.get() }, [1, nil, 3, nil, 5])
    XCTAssertEqual(mock.optionalResilientArray, [2, 5])
    XCTAssertEqual(mock.$optionalResilientArray.errors.count, 3)
    XCTAssertEqual(mock.$optionalResilientArray.results.map { try? $0.get() }, [nil, 2, nil, nil, 5])
  }

}
