import XCTest

@testable import PactSwift

class MatcherCombinedTests: MatcherTestCase {

	func testMatcher_And_SerializesToJSON() throws {
		let json = try jsonString(for: .and("2024-01-01", .notEmpty(), .date("2024-01-01", format: "yyyy-MM-dd")))

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : [
			    {
			      "pact:matcher:type" : "notEmpty",
			      "value" : "non-empty"
			    },
			    {
			      "format" : "yyyy-MM-dd",
			      "pact:matcher:type" : "date",
			      "value" : "2024-01-01"
			    }
			  ],
			  "value" : "2024-01-01"
			}
			"""#
		)
	}

	func testMatcher_Expression_SerializesToJSON() throws {
		let json = try jsonString(for: .matching("matching(type, 'Name')", example: "Name"))

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "matching(type, 'Name')",
			  "value" : "Name"
			}
			"""#
		)
	}
}
