import Foundation
import Synchronization

/// Serves canned responses for every request of an ephemeral session —
/// network tests without a network, exercising the real `URLSession` path.
///
/// State is `Mutex`-guarded because Swift Testing runs tests in parallel.
/// Tests must stub distinct URLs (or run in a `.serialized` suite) to avoid
/// cross-talk.
final class StubURLProtocol: URLProtocol {
    typealias Stub = Result<(statusCode: Int, data: Data), URLError>

    private static let stubs = Mutex<[URL: Stub]>([:])
    private static let requestCounts = Mutex<[URL: Int]>([:])

    static func setStub(_ stub: Stub, for url: URL) {
        stubs.withLock { $0[url] = stub }
    }

    static func requestCount(for url: URL) -> Int {
        requestCounts.withLock { $0[url] ?? 0 }
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    // URLProtocol declares these as `class func` — overrides cannot be static.
    // swiftlint:disable:next static_over_final_class
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    // swiftlint:disable:next static_over_final_class
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url else { return }
        Self.requestCounts.withLock { $0[url, default: 0] += 1 }

        let stub = Self.stubs.withLock { $0[url] } ?? .failure(URLError(.unsupportedURL))
        switch stub {
        case let .success((statusCode, data)):
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil,
            ) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
