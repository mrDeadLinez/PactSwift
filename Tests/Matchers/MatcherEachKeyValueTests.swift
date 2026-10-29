import XCTest

@testable import PactSwift

class MatcherEachKeyValueTests: MatcherTestCase {

	func testMatcher_EachKey_SerializesToJSON() throws {
		let json = try jsonString(for: .eachKey(["123": "A book"], matching: .regex(#"\d+"#, example: "123")))

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "eachKey",
			  "rules" : [
			    {
			      "pact:matcher:type" : "regex",
			      "regex" : "\\d+",
			      "value" : "123"
			    }
			  ],
			  "value" : {
			    "123" : "A book"
			  }
			}
			"""#
		)
	}

	func testMatcher_EachValue_SerializesToJSON() throws {
		let json = try jsonString(for: .eachValue(["price": 1.5], matching: .decimal(1.5)))

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "eachValue",
			  "rules" : [
			    {
			      "pact:matcher:type" : "decimal",
			      "value" : 1.5
			    }
			  ],
			  "value" : {
			    "price" : 1.5
			  }
			}
			"""#
		)
	}
}
