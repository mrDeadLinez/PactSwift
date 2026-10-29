//
//  Created by Marko Justinek on 15/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import XCTest

@testable import PactSwift

class FromProviderStateTests: MatcherTestCase {

	func testFromProviderState_SerializesToJSON() throws {
		let json = try jsonString(for: .fromProviderState("/users/${id}", example: "/users/1"))

		XCTAssertEqual(
			json,
			#"""
			{
			  "dataType" : "STRING",
			  "expression" : "/users/${id}",
			  "pact:generator:type" : "ProviderState",
			  "pact:matcher:type" : "type",
			  "value" : "/users/1"
			}
			"""#
		)
	}

	func testFromProviderState_SetsDataTypeFromExample() throws {
		XCTAssertTrue(try jsonString(for: .fromProviderState("id", example: 1)).contains(#""dataType" : "INTEGER""#))
		XCTAssertTrue(try jsonString(for: .fromProviderState("price", example: 1.5)).contains(#""dataType" : "DECIMAL""#))
		XCTAssertTrue(try jsonString(for: .fromProviderState("active", example: true)).contains(#""dataType" : "BOOLEAN""#))
		XCTAssertTrue(try jsonString(for: .fromProviderState("user", example: ["id": 1])).contains(#""dataType" : "RAW""#))
	}
}
