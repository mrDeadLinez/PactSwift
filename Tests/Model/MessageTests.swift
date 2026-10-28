import XCTest
@testable import PactSwift

final class MessageTests: InteractionTestCase {

	func testAsynchronousMessage() throws {
		let message = try builder
			.expectsToReceive("an order created event")
			.given("An order exists")
			.jsonBody(.like([
				"id": .randomInteger(1...9),
				"status": .oneOf(["created", "paid"], example: "created")
			]))
			.metadata("queue", matching: .regex("^orders-\\d+$", example: "orders-1"))

		try builder.verify(message) { message in
			struct Event: Decodable {
				var id: Int
				var status: String
			}

			let event = try JSONDecoder().decode(Event.self, from: message.contents)
			XCTAssertTrue((1...9).contains(event.id))
			XCTAssertEqual(event.status, "created")
			XCTAssertEqual(message.metadata["queue"], "orders-1")
		}
	}

	func testSynchronousMessage() throws {
		let message = try builder
			.synchronousMessage("a request for the order status")
			.withRequest { request in
				try request.jsonBody(.like(["orderId": .integer(1)]))
			}
			.willRespond { response in
				try response.jsonBody(.like(["status": .like("created")]))
			}

		try builder.verify(message) { message in
			XCTAssertEqual(try JSONSerialization.jsonObject(with: message.request.contents) as? [String: Int], ["orderId": 1])
			XCTAssertEqual(message.responses.count, 1)
			XCTAssertEqual(try JSONSerialization.jsonObject(with: message.responses[0].contents) as? [String: String], ["status": "created"])
		}
	}

}
