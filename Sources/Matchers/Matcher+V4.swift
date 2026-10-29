//
//  Created by Oliver Jones on 12/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
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

import Foundation

// MARK: - Pact Specification v4 matchers

public extension Matcher {
	/// A matcher that checks that an array contains at least one item matching each of the `variants`, in any order.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - variants: The items the array has to contain. They can contain matchers.
	///
	static func arrayContains<T: Encodable>(_ variants: [T]) -> AnyMatcher {
		ArrayContainsMatcher(variants: variants).asAny()
	}

	/// A matcher that checks that an array contains at least one item matching each of the `variants`, in any order.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - variants: The matchers of the items the array has to contain.
	///
	static func arrayContains(_ variants: [AnyMatcher]) -> AnyMatcher {
		ArrayContainsMatcher(variants: variants).asAny()
	}

	/// A matcher that matches the response status code.
	///
	/// Apply it to the response status with `Interaction.willRespond(with:builder:)` or `Interaction.Response.status(matching:)`.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - statusCode: The status class or the list of status codes to match
	///   - example: The status code the mock server responds with. Defaults to a code in the matched range.
	///
	static func statusCode(_ statusCode: HTTPStatus, example: Int? = nil) -> AnyMatcher {
		StatusCodeMatcher(status: statusCode, value: example ?? statusCode.example).asAny()
	}

	/// A matcher that matches a value that must be present and not empty (not null or the empty string).
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	static func notEmpty() -> AnyMatcher {
		notEmpty("non-empty")
	}

	/// A matcher that matches a value that must be present and not empty (not null, the empty string, an empty array or an empty object).
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - value: An example value.
	///
	static func notEmpty<T: Encodable>(_ value: T) -> AnyMatcher {
		GenericMatcher(type: "notEmpty", value: value).asAny()
	}

	/// A matcher that matches a value that must be valid based on the `semver` specification.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - value: An example value (eg: `"1.2.3"`)
	///
	static func semver(_ value: String) -> AnyMatcher {
		GenericMatcher(type: "semver", value: value).asAny()
	}

	/// A matcher that matches every key of a map/dictionary against the `rules`.
	///
	/// Eg: `.eachKey(["123": "A book"], matching: .regex(#"\d+"#, example: "123"))`.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - value: An example dictionary.
	///   - rules: The matchers every key must satisfy.
	///
	static func eachKey<T: Encodable>(_ value: [String: T], matching rules: AnyMatcher...) -> AnyMatcher {
		precondition(rules.isEmpty == false, "At least one matcher is required")
		return EachMatcher(type: "eachKey", value: value, rules: rules).asAny()
	}

	/// A matcher that matches every value of a map/dictionary against the `rules`.
	///
	/// Eg: `.eachValue(["price": 1.23], matching: .decimal(1.23))`.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - value: An example dictionary.
	///   - rules: The matchers every value must satisfy.
	///
	static func eachValue<T: Encodable>(_ value: [String: T], matching rules: AnyMatcher...) -> AnyMatcher {
		precondition(rules.isEmpty == false, "At least one matcher is required")
		return EachMatcher(type: "eachValue", value: value, rules: rules).asAny()
	}

	/// A matcher defined by a matching rule expression, eg: `.matching("matching(type, 'Name')", example: "Name")`.
	///
	/// See [Matching Rule definition expressions](https://docs.rs/pact_models/latest/pact_models/matchingrules/expressions/index.html).
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - expression: The matching rule expression.
	///   - example: The example value. It has to be the value the expression defines.
	///
	static func matching<T: Encodable>(_ expression: String, example: T) -> AnyMatcher {
		GenericMatcher(type: expression, value: example).asAny()
	}
}

private struct ArrayContainsMatcher<VariantType: Encodable>: Matcher {
	let type = "arrayContains"
	let variants: [VariantType]

	enum CodingKeys: String, CodingKey {
		case type = "pact:matcher:type"
		case variants
	}
}

private struct EachMatcher<ValueType: Encodable>: Matcher {
	let type: String
	let value: [String: ValueType]
	let rules: [AnyMatcher]

	enum CodingKeys: String, CodingKey {
		case type = "pact:matcher:type"
		case value
		case rules
	}
}

private struct StatusCodeMatcher: Matcher {
	let type = "statusCode"
	let status: HTTPStatus
	let value: Int

	enum CodingKeys: String, CodingKey {
		case type = "pact:matcher:type"
		case status
		case value
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type, forKey: .type)
		switch status {
		case .information: try container.encode("info", forKey: .status)
		case .success: try container.encode("success", forKey: .status)
		case .redirect: try container.encode("redirect", forKey: .status)
		case .clientError: try container.encode("clientError", forKey: .status)
		case .serverError: try container.encode("serverError", forKey: .status)
		case .nonError: try container.encode("nonError", forKey: .status)
		case .error: try container.encode("error", forKey: .status)
		case .statusCodes(let codes): try container.encode(codes, forKey: .status)
		}
		try container.encode(value, forKey: .value)
	}
}

private extension HTTPStatus {
	var example: Int {
		switch self {
		case .information: return 100
		case .success, .nonError: return 200
		case .redirect: return 300
		case .clientError, .error: return 400
		case .serverError: return 500
		case .statusCodes(let codes): return codes.first ?? 200
		}
	}
}
