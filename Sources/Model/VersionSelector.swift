//
//  Created by Marko Justinek on 19/8/21.
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

import Foundation

/// Provides a way to configure which pacts the provider verifies.
public struct VersionSelector: Codable, Equatable {

	// MARK: - Properties

	/// The name of the tag which applies to the pacticipant versions of the pacts to verify
	let tag: String?

	/// Whether or not to verify only the pact that belongs to the latest application version
	let latest: Bool?

	/// A fallback tag if a pact for the specified `tag` does not exist
	let fallbackTag: String?

	/// Filter pacts by the specified consumer
	///
	/// When omitted, all consumers are included.
	let consumer: String?

	/// The latest version of each consumer's main branch
	let mainBranch: Bool?

	/// The latest version of each consumer on the branch
	let branch: String?

	/// A fallback branch if a pact for the specified `branch` does not exist
	let fallbackBranch: String?

	/// The latest version of each consumer on the branch with the same name as the provider branch
	let matchingBranch: Bool?

	/// The versions of each consumer currently deployed or released to any environment
	let deployedOrReleased: Bool?

	/// The versions of each consumer currently deployed
	let deployed: Bool?

	/// The versions of each consumer currently released
	let released: Bool?

	/// The environment the consumer versions are deployed or released to
	let environment: String?

	// MARK: - Initialization

	/// Defines a version configuration for which pacts the provider verifies
	///
	/// - Parameters:
	///   - tag: The version `tag` name of the consumer to verify
	///   - fallbackTag: The version `tag` to use if the initial `tag` does not exist
	///   - latest: Whether to verify only the pact belonging to the latest application version
	///   - consumer: Filter pacts by the specified consumer
	///
	/// See [https://docs.pact.io/selectors](https://docs.pact.io/selectors) for more context.
	///
	public init(tag: String, fallbackTag: String? = nil, latest: Bool = true, consumer: String? = nil) {
		self.init(tag: tag, latest: latest, fallbackTag: fallbackTag, consumer: consumer)
	}

	private init(
		tag: String? = nil,
		latest: Bool? = nil,
		fallbackTag: String? = nil,
		consumer: String? = nil,
		mainBranch: Bool? = nil,
		branch: String? = nil,
		fallbackBranch: String? = nil,
		matchingBranch: Bool? = nil,
		deployedOrReleased: Bool? = nil,
		deployed: Bool? = nil,
		released: Bool? = nil,
		environment: String? = nil
	) {
		self.tag = tag
		self.latest = latest
		self.fallbackTag = fallbackTag
		self.consumer = consumer
		self.mainBranch = mainBranch
		self.branch = branch
		self.fallbackBranch = fallbackBranch
		self.matchingBranch = matchingBranch
		self.deployedOrReleased = deployedOrReleased
		self.deployed = deployed
		self.released = released
		self.environment = environment
	}

	/// The latest version of each consumer's main branch
	public static func mainBranch(consumer: String? = nil) -> VersionSelector {
		VersionSelector(consumer: consumer, mainBranch: true)
	}

	/// The latest version of each consumer on the `branch`, or on the `fallbackBranch` when there is none
	public static func branch(_ branch: String, fallbackBranch: String? = nil, consumer: String? = nil) -> VersionSelector {
		VersionSelector(consumer: consumer, branch: branch, fallbackBranch: fallbackBranch)
	}

	/// The latest version of each consumer on the branch with the same name as the provider branch set in `PactBroker`
	public static func matchingBranch(consumer: String? = nil) -> VersionSelector {
		VersionSelector(consumer: consumer, matchingBranch: true)
	}

	/// The versions of each consumer currently deployed or released to any environment
	public static func deployedOrReleased(consumer: String? = nil) -> VersionSelector {
		VersionSelector(consumer: consumer, deployedOrReleased: true)
	}

	/// The versions of each consumer currently deployed to the `environment`, or to any environment when `nil`
	public static func deployed(to environment: String? = nil, consumer: String? = nil) -> VersionSelector {
		VersionSelector(consumer: consumer, deployed: true, environment: environment)
	}

	/// The versions of each consumer currently released to the `environment`, or to any environment when `nil`
	public static func released(to environment: String? = nil, consumer: String? = nil) -> VersionSelector {
		VersionSelector(consumer: consumer, released: true, environment: environment)
	}

	/// The versions of each consumer currently deployed or released to the `environment`
	public static func environment(_ environment: String, consumer: String? = nil) -> VersionSelector {
		VersionSelector(consumer: consumer, environment: environment)
	}

}

// MARK: - Internal

extension VersionSelector {

	/// Converts to JSON string
	///
	/// - Returns: A `String` representing `ProviderVerifier` in JSON format
	///
	func toJSONString() throws -> String {
		let jsonEncoder = JSONEncoder()
		let jsonData = try jsonEncoder.encode(self)
		guard let jsonString = String(data: jsonData, encoding: .utf8) else {
			throw ProviderVerifier.VerificationError.error("Invalid consumer version selector specified: \(self)")
		}

		return jsonString
	}

}
