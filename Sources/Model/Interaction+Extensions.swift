//
//  Created by Oliver Jones on 9/1/2023.
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
@_exported import PactSwiftMockServer

public extension Interaction {

	/// Configures the request for the Interaction.
	/// - Throws: ``Error/canNotBeModified`` if the interaction or Pact can't be modified (i.e. the mock server for it has already started)
	/// - Parameters:
	///   - method: The request method. Defaults to ``HTTPMethod/GET``.
	///   - regex: The request path regex matcher.
	///   - example: An example path.
	///   - builder: A ``RequestBuilder`` closure.
	func withRequest(method: HTTPMethod = .GET, regex: String, example: String, builder: RequestBuilder = { _ in }) throws -> Self {
		try withRequest(
			method: method,
			path: String(data: JSONEncoder().encode(AnyMatcher.regex(regex, example: example)), encoding: .utf8)!,
			builder: builder
		)
	}

	/// Configures the response for the Interaction with a status matcher, eg: `.statusCode(.clientError)`.
	/// - Throws: ``Error/canNotBeModified`` if the interaction or Pact can't be modified (i.e. the mock server for it has already started)
	/// - Parameters:
	///   - status: The response status matcher.
	///   - builder: A ``ResponseBuilder`` closure.
	@discardableResult
	func willRespond(with status: AnyMatcher, builder: ResponseBuilder = { _ in }) throws -> Self {
		try willRespond(with: 200) { response in
			try response.status(matching: status)
			try builder(response)
		}
	}

}

public extension Interaction.Response {

	/// Configures the response status with a matcher, eg: `.statusCode(.clientError)`.
	/// - Throws: ``Interaction/Error/canNotBeModified`` if the interaction or Pact can't be modified (i.e. the mock server for it has already started)
	@discardableResult
	func status(matching status: AnyMatcher) throws -> Self {
		try self.status(String(data: JSONEncoder().encode(status), encoding: .utf8)!)
	}

}
