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

public extension ProviderVerifier {

	/// Defines the options to use when verifying a provider
	struct Options {

		// MARK: - Types

		/// Logging level for provider verification
		@available(*, deprecated, message: "Configure Pact logging with `Logging.initialize(_:)` from PactSwiftMockServer")
		public enum LogLevel: String {
			case error
			case warn
			case info
			case debug
			case trace
			case none
		}

		/// The source of Pact files
		public enum PactsSource {

			/// Verify pacts on a Pact Broker
			case broker(PactBroker)

			/// Verify pacts in directories
			case directories([String])

			/// Verify specific pact files
			case files([String])

			/// Verify specific pacts at URLs
			case urls([URL])
		}

		/// Filter pacts
		public enum FilterPacts {

			/// Only validate interactions that have no defined provider state
			case noState

			/// Only validate interactions whose provider states match this filter
			case states([String])

			/// Only validate interactions whose descriptions match this filter
			case descriptions([String])

			/// Consumer name to filter the pacts to be verified
			case consumers([String])
		}

		// MARK: - Properties

		/// The port of provider being verified
		let port: Int

		/// URL of the provider being verified
		let providerURL: URL?

		/// Only validated interactions that match this filter
		let filterPacts: FilterPacts?

		/// Pacts source
		let pactsSource: PactsSource

		/// URL to post state change requests to
		let stateChangeURL: URL?

		// MARK: - Initialization

		/// Defines the options to use when verifying a provider
		///
		/// - Parameters:
		///   - provider: The provider information
		///   - pactsSource: The locations of pacts
		///   - filter: Only validates the interactions that match the filter
		///   - stateChangeURL: URL to post state change requests to
		///
		/// The verification logs are written to the sinks configured with `Logging.initialize(_:)` from PactSwiftMockServer.
		///
		public init(
			provider: Provider,
			pactsSource: PactsSource,
			filter: FilterPacts? = nil,
			stateChangeURL: URL? = nil
		) {
			self.providerURL = provider.url
			self.port = provider.port
			self.pactsSource = pactsSource
			self.filterPacts = filter
			self.stateChangeURL = stateChangeURL
		}

		@available(*, deprecated, message: "`logLevel` is ignored. Configure Pact logging with `Logging.initialize(_:)` from PactSwiftMockServer")
		public init(
			provider: Provider,
			pactsSource: PactsSource,
			filter: FilterPacts? = nil,
			stateChangeURL: URL? = nil,
			logLevel: LogLevel
		) {
			self.init(provider: provider, pactsSource: pactsSource, filter: filter, stateChangeURL: stateChangeURL)
		}
	}

}

extension ProviderVerifier.Options {

	/// The options passed to the PactSwiftMockServer `Verifier`
	var verificationOptions: ProviderVerificationOptions {
		var options = ProviderVerificationOptions(provider: .init(url: providerURL, port: port), sources: [])

		switch pactsSource {
		case .broker(let broker):
			options.provider.name = broker.providerName
			options.sources = [.broker(broker.verificationSource)]

			// Publishing verification results back to Broker
			if broker.publishVerificationResult, let providerVersion = broker.providerVersion, providerVersion.isEmpty == false {
				options.publish = .init(providerVersion: providerVersion, providerTags: broker.providerTags ?? [])
			}

		case .directories(let pactDirs):
			options.sources = pactDirs.map { .directory($0) }

		case .files(let files):
			options.sources = files.map { .file($0) }

		case .urls(let pactURLs):
			options.sources = pactURLs.map { .url($0) }
		}

		switch filterPacts {
		case .noState:
			options.filter = .init(noState: true)

		case .states(let states) where states.isEmpty == false:
			options.filter = .init(state: matchingAny(of: states))

		case .descriptions(let descriptions) where descriptions.isEmpty == false:
			options.filter = .init(description: matchingAny(of: descriptions))

		case .consumers(let consumers):
			options.consumers = consumers

		default:
			break
		}

		options.stateChangeURL = stateChangeURL

		return options
	}

}

private extension PactBroker {

	var verificationSource: ProviderVerificationOptions.Broker {
		let authentication: ProviderVerificationOptions.Authentication
		switch self.authentication {
		case .auth(let auth): authentication = .basic(username: auth.username, password: auth.password)
		case .token(let auth): authentication = .token(auth.token)
		}

		let consumerVersionSelectors: [String] = consumerTags?.compactMap {
			do {
				return try $0.toJSONString()
			} catch {
				Logger.log(message: "Failed to convert consumer version selector to JSON representation: \($0)")
				return nil
			}
		} ?? []

		return .init(
			url: url,
			authentication: authentication,
			// WIP pacts are only verified with pending pacts enabled
			enablePending: includePending == true || includeWIP != nil,
			includeWIPPactsSince: includeWIP?.sinceDate.iso8601short,
			providerTags: providerTags ?? [],
			consumerVersionSelectors: consumerVersionSelectors
		)
	}

}

/// A regular expression matching any of the given regular expressions
private func matchingAny(of patterns: [String]) -> String {
	patterns.count == 1 ? patterns[0] : patterns.map { "(?:\($0))" }.joined(separator: "|")
}

private extension Date {

	/// Date represented as string in short ISO8601 format (eg: "2021-08-24")
	var iso8601short: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-dd"
		return formatter.string(from: self)
	}

}
