import XCTest

@testable import PactSwift

class MatcherArrayContainsTests: MatcherTestCase {

	func testMatcher_ArrayContains_SerializesToJSON() throws {
		let json = try jsonString(for: .arrayContains([.like(["id": 1]), .equals("admin")]))

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "arrayContains",
			  "variants" : [
			    {
			      "pact:matcher:type" : "type",
			      "value" : {
			        "id" : 1
			      }
			    },
			    {
			      "pact:matcher:type" : "equality",
			      "value" : "admin"
			    }
			  ]
			}
			"""#
		)
	}

	func testMatcher_ArrayContainsValues_SerializesToJSON() throws {
		let json = try jsonString(for: .arrayContains(["a", "b"]))

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "arrayContains",
			  "variants" : [
			    "a",
			    "b"
			  ]
			}
			"""#
		)
	}
}
