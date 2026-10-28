import Foundation
import PactSwiftMockServer

public extension MetadataBuilder {

	/// Configures a metadata entry for the message with a matcher, eg: `.regex("^orders-\\d+$", example: "orders-1")`.
	/// - Throws: ``PactInteraction/Error/canNotBeModified`` if the interaction or Pact can't be modified.
	@discardableResult
	func metadata(_ name: String, matching: AnyMatcher) throws -> Self {
		try metadata(name, json: String(data: JSONEncoder().encode(matching), encoding: .utf8)!)
	}

}
