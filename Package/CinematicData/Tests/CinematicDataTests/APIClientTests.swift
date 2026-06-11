@testable import CinematicData
import CinematicDomain
import Foundation
import Testing

/// Each test stubs its own unique URL, so the suite is parallel-safe.
struct APIClientTests {
    private let client = APIClient(session: StubURLProtocol.makeSession())

    @Test("Successful responses decode into the requested DTO")
    func successDecodes() async throws {
        let endpoint = ITunesEndpoint.lookup(id: "success")
        StubURLProtocol.setStub(.success((200, SampleJSON.lookupResponse)), for: endpoint.url)

        let response: LookupResponseDTO = try await client.fetch(endpoint)

        #expect(response.resultCount == 1)
    }

    @Test("404 becomes the domain's notFound")
    func notFound() async {
        let endpoint = ITunesEndpoint.lookup(id: "missing")
        StubURLProtocol.setStub(.success((404, Data())), for: endpoint.url)

        await #expect(throws: MovieError.notFound) {
            let _: LookupResponseDTO = try await client.fetch(endpoint)
        }
    }

    @Test("Other failure statuses keep their code")
    func serverError() async {
        let endpoint = ITunesEndpoint.lookup(id: "boom")
        StubURLProtocol.setStub(.success((500, Data())), for: endpoint.url)

        await #expect(throws: MovieError.invalidResponse(statusCode: 500)) {
            let _: LookupResponseDTO = try await client.fetch(endpoint)
        }
    }

    @Test("Connectivity failures become offline")
    func offline() async {
        let endpoint = ITunesEndpoint.lookup(id: "offline")
        StubURLProtocol.setStub(.failure(URLError(.notConnectedToInternet)), for: endpoint.url)

        await #expect(throws: MovieError.offline) {
            let _: LookupResponseDTO = try await client.fetch(endpoint)
        }
    }

    @Test("Timeouts become timedOut")
    func timeout() async {
        let endpoint = ITunesEndpoint.lookup(id: "slow")
        StubURLProtocol.setStub(.failure(URLError(.timedOut)), for: endpoint.url)

        await #expect(throws: MovieError.timedOut) {
            let _: LookupResponseDTO = try await client.fetch(endpoint)
        }
    }

    @Test("Malformed payloads become decodingFailed with a field diagnosis")
    func decodingFailure() async throws {
        let endpoint = ITunesEndpoint.lookup(id: "garbage")
        StubURLProtocol.setStub(.success((200, Data("{}".utf8))), for: endpoint.url)

        let error = await #expect(throws: MovieError.self) {
            let _: LookupResponseDTO = try await client.fetch(endpoint)
        }
        guard case .decodingFailed = error else {
            Issue.record("Expected decodingFailed, got \(String(describing: error))")
            return
        }
    }
}
