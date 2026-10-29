//
//  Created by Marko Justinek on 28/8/21.
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

final class VersionSelectorTests: XCTestCase {

	func testVersionSelectorInitializes() {
		let testSubject = VersionSelector(tag: "test-tag")

		XCTAssertEqual(testSubject.tag, "test-tag")
		XCTAssertNil(testSubject.fallbackTag)
		XCTAssertEqual(testSubject.latest, true)
		XCTAssertNil(testSubject.consumer)
	}

	func testVersionSelectorSetsFallbackTag() {
		let testSubject = VersionSelector(tag: "test-tag", fallbackTag: "fallback-tag")

		XCTAssertEqual(testSubject.tag, "test-tag")
		XCTAssertEqual(testSubject.fallbackTag, "fallback-tag")
	}

	func testVersionSelectorSetsLatest() {
		let testSubject = VersionSelector(tag: "test-tag", latest: false)

		XCTAssertEqual(testSubject.latest, false)
	}

	func testVersionSelectorSetsConsumer() {
		let testSubject = VersionSelector(tag: "test-tag", consumer: "api-consumer")

		XCTAssertEqual(testSubject.consumer, "api-consumer")
	}

	func testVersionSelectorJSONString() throws {
		let testSubject = try VersionSelector(tag: "test", fallbackTag: "main", latest: true, consumer: "api-consumer").toJSONString()

		XCTAssertTrue(testSubject.contains("\"tag\":\"test\""))
		XCTAssertTrue(testSubject.contains("\"fallbackTag\":\"main\""))
		XCTAssertTrue(testSubject.contains("\"latest\":true"))
		XCTAssertTrue(testSubject.contains("\"consumer\":\"api-consumer\""))
	}

	func testBranchSelectorsJSON() throws {
		XCTAssertEqual(try json(.mainBranch()), #"{"mainBranch":true}"#)
		XCTAssertEqual(try json(.branch("feat/x", fallbackBranch: "main", consumer: "app")), #"{"branch":"feat\/x","consumer":"app","fallbackBranch":"main"}"#)
		XCTAssertEqual(try json(.matchingBranch()), #"{"matchingBranch":true}"#)
	}

	func testEnvironmentSelectorsJSON() throws {
		XCTAssertEqual(try json(.deployedOrReleased()), #"{"deployedOrReleased":true}"#)
		XCTAssertEqual(try json(.deployed(to: "production")), #"{"deployed":true,"environment":"production"}"#)
		XCTAssertEqual(try json(.released()), #"{"released":true}"#)
		XCTAssertEqual(try json(.environment("test", consumer: "app")), #"{"consumer":"app","environment":"test"}"#)
	}

	private func json(_ selector: VersionSelector) throws -> String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .sortedKeys
		return String(data: try encoder.encode(selector), encoding: .utf8)!
	}

}
