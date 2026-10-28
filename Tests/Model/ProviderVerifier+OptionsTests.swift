//
//  Created by Marko Justinek on 29/8/21.
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

import PactSwiftMockServer
@testable import PactSwift

final class ProviderVerifierOptionsTests: XCTestCase {

	private let brokerURL = URL(string: "https://broker.url")!

	func testConfiguredProvider() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(url: URL(string: "https://localhost/api")!, port: 1234),
			pactsSource: .directories(["/tmp/pacts"])
		)

		XCTAssertEqual(testSubject.verificationOptions.provider, .init(url: URL(string: "https://localhost/api")!, port: 1234))
	}

	func testWhenPactSourceIsDirectories() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .directories(["/tmp/pacts", "/tmp/more-pacts"])
		)

		XCTAssertEqual(testSubject.verificationOptions.provider, .init(port: 8080))
		XCTAssertEqual(testSubject.verificationOptions.sources, [.directory("/tmp/pacts"), .directory("/tmp/more-pacts")])
	}

	func testWhenPactsSourceIsFiles() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .files(["/tmp/pacts/one.json", "/tmp/pacts/two.json"])
		)

		XCTAssertEqual(testSubject.verificationOptions.sources, [.file("/tmp/pacts/one.json"), .file("/tmp/pacts/two.json")])
	}

	func testWhenPactsSourceIsURLs() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .urls([URL(string: "http://some.url/file.json")!])
		)

		XCTAssertEqual(testSubject.verificationOptions.sources, [.url(URL(string: "http://some.url/file.json")!)])
	}

	func testWithStateChangeURL() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			stateChangeURL: URL(string: "https://provider.url/stateChangeURL")!
		)

		XCTAssertEqual(testSubject.verificationOptions.stateChangeURL, URL(string: "https://provider.url/stateChangeURL")!)
	}

	func testWithoutFilter() {
		let testSubject = ProviderVerifier.Options(provider: .init(port: 8080), pactsSource: .directories(["/tmp/pacts"]))

		XCTAssertNil(testSubject.verificationOptions.filter)
		XCTAssertEqual(testSubject.verificationOptions.consumers, [])
	}

	func testWithFilterNoState() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .noState
		)

		XCTAssertEqual(testSubject.verificationOptions.filter, .init(noState: true))
	}

	func testWithFilterState() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .states(["state A"])
		)

		XCTAssertEqual(testSubject.verificationOptions.filter, .init(state: "state A"))
	}

	func testWithFilterStatesMatchesAnyOfThem() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .states(["state A", "state B"])
		)

		XCTAssertEqual(testSubject.verificationOptions.filter, .init(state: "(?:state A)|(?:state B)"))
	}

	func testWithFilterDescriptionsMatchesAnyOfThem() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .descriptions(["A description", "B description"])
		)

		XCTAssertEqual(testSubject.verificationOptions.filter, .init(description: "(?:A description)|(?:B description)"))
	}

	func testWithFilterConsumers() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .consumers(["Mobile Consumer", "Web Consumer"])
		)

		XCTAssertNil(testSubject.verificationOptions.filter)
		XCTAssertEqual(testSubject.verificationOptions.consumers, ["Mobile Consumer", "Web Consumer"])
	}

	func testWithPactBrokerUsingToken() {
		let testBroker = PactBroker(url: brokerURL, auth: .token(PactBroker.APIToken("test-token")), providerName: "API Provider Name")

		let testSubject = ProviderVerifier.Options(provider: .init(port: 1234), pactsSource: .broker(testBroker))

		XCTAssertEqual(testSubject.verificationOptions.provider, .init(name: "API Provider Name", port: 1234))
		XCTAssertEqual(testSubject.verificationOptions.sources, [.broker(.init(url: "https://broker.url", authentication: .token("test-token")))])
		XCTAssertNil(testSubject.verificationOptions.publish)
	}

	func testWithPactBrokerBasicAuth() {
		let testBroker = PactBroker(url: brokerURL, auth: .auth(.init(username: "test-user", password: "test-pass")), providerName: "API Provider Name")

		let testSubject = ProviderVerifier.Options(provider: .init(port: 1234), pactsSource: .broker(testBroker))

		XCTAssertEqual(
			testSubject.verificationOptions.sources,
			[.broker(.init(url: "https://broker.url", authentication: .basic(username: "test-user", password: "test-pass")))]
		)
	}

	func testPublishingVerification() {
		let testBroker = PactBroker(
			url: brokerURL,
			auth: .token(PactBroker.APIToken("test-token")),
			providerName: "API Provider Name",
			publishResults: .init(providerVersion: "test-998877", providerTags: ["test", "unit"])
		)

		let testSubject = ProviderVerifier.Options(provider: .init(port: 1234), pactsSource: .broker(testBroker))

		XCTAssertEqual(testSubject.verificationOptions.publish, .init(providerVersion: "test-998877", providerTags: ["test", "unit"]))
		XCTAssertEqual(brokerSource(of: testSubject)?.providerTags, ["test", "unit"])
	}

	func testPublishingVerificationWithoutTags() {
		let testBroker = PactBroker(
			url: brokerURL,
			auth: .token(PactBroker.APIToken("test-token")),
			providerName: "API Provider Name",
			publishResults: .init(providerVersion: "test-123456")
		)

		let testSubject = ProviderVerifier.Options(provider: .init(port: 1234), pactsSource: .broker(testBroker))

		XCTAssertEqual(testSubject.verificationOptions.publish, .init(providerVersion: "test-123456"))
	}

	func testBrokerWithConsumerTags() throws {
		let selectors = [
			VersionSelector(tag: "prod", fallbackTag: "main", latest: true, consumer: "Test-app"),
			VersionSelector(tag: "v2.3.5", fallbackTag: "prod", latest: false, consumer: "Web-app"),
		]
		let testBroker = PactBroker(url: brokerURL, auth: .token(PactBroker.APIToken("test-token")), providerName: "API Provider Name", consumerTags: selectors)

		let testSubject = ProviderVerifier.Options(provider: .init(port: 1234), pactsSource: .broker(testBroker))

		let decoded = try XCTUnwrap(brokerSource(of: testSubject)).consumerVersionSelectors.map {
			try JSONDecoder().decode(VersionSelector.self, from: Data($0.utf8))
		}
		XCTAssertEqual(decoded, selectors)
	}

	func testBrokerWithPendingPacts() {
		let testBroker = PactBroker(url: brokerURL, auth: .token(PactBroker.APIToken("test-token")), providerName: "API Provider Name", includePending: true)

		let testSubject = ProviderVerifier.Options(provider: .init(port: 1234), pactsSource: .broker(testBroker))

		XCTAssertEqual(brokerSource(of: testSubject)?.enablePending, true)
	}

	func testBrokerDefaultsNotIncludePendingOrWIPPacts() {
		let testBroker = PactBroker(url: brokerURL, auth: .token(PactBroker.APIToken("test-token")), providerName: "API Provider Name")

		let testSubject = ProviderVerifier.Options(provider: .init(port: 1234), pactsSource: .broker(testBroker))

		XCTAssertEqual(brokerSource(of: testSubject)?.enablePending, false)
		XCTAssertNil(brokerSource(of: testSubject)?.includeWIPPactsSince)
	}

	func testBrokerIncludeWIPPactsEnablesPendingPacts() {
		let testDate = Date()
		let testBroker = PactBroker(url: brokerURL, auth: .token(PactBroker.APIToken("test-token")), providerName: "API Provider Name", includeWIP: WIPPacts(since: testDate))

		let testSubject = ProviderVerifier.Options(provider: .init(port: 1234), pactsSource: .broker(testBroker))

		XCTAssertEqual(brokerSource(of: testSubject)?.enablePending, true)
		XCTAssertEqual(brokerSource(of: testSubject)?.includeWIPPactsSince, isoDate(testDate))
	}

}

private extension ProviderVerifierOptionsTests {

	func brokerSource(of options: ProviderVerifier.Options) -> ProviderVerificationOptions.Broker? {
		guard case .broker(let broker) = options.verificationOptions.sources.first else {
			return nil
		}
		return broker
	}

	func isoDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-dd"
		return formatter.string(from: date)
	}

}
