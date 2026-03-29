//
//  Mocks.swift
//  CoreNetwork
//
//  Created by xdmGzDev on 28/3/26.
//

import Foundation
@testable import CoreNetwork

final class MockSession: @unchecked Sendable, Session {
    var responses: [(data: Data, response: URLResponse)] = []
    var error: Error? = nil
    private(set) var callCount = 0
    private(set) var lastRequest: URLRequest? = nil

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        lastRequest = request
        if let error { throw error }
        guard !responses.isEmpty else {
            return (Data(), makeHTTPResponse(statusCode: 200))
        }
        let index = min(callCount - 1, responses.count - 1)
        return responses[index]
    }

    func makeHTTPResponse(statusCode: Int, mimeType: String = "application/json") -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com/api/test")!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": mimeType]
        )!
    }
}

struct MockEndpoint: EndpointProvider {
    var scheme: CoreHTTPScheme = .https
    var baseURL: String = "example.com"
    var path: String = "/api/test"
    var method: CoreHTTPMethod = .get
    var authorization: CoreHTTPAuthorizationMethod? = nil
    var headers: [CoreHTTPHeaderKey: String]? = nil
    var queryItems: [URLQueryItem]? = nil
    var body: (any Encodable & Sendable)? = nil
    var mockFile: String? = nil
    var multipart: Multipart? = nil
}

struct AlwaysRetryInterceptor: RequestInterceptor {
    var maxRetryAttempts: Int? = 3
    func retry(_ request: URLRequest, for session: any Session, dueTo error: Error) async throws -> RetryResult {
        .retry
    }
}

struct DoNotRetryInterceptor: RequestInterceptor {
    var maxRetryAttempts: Int? = 3
}

struct OverrideErrorInterceptor: RequestInterceptor {
    struct OverrideError: Error {}
    var maxRetryAttempts: Int? = 3
    func retry(_ request: URLRequest, for session: any Session, dueTo error: Error) async throws -> RetryResult {
        .doNotRetryWithError(OverrideError())
    }
}

struct TokenAddingInterceptor: RequestInterceptor {
    let token: String
    var maxRetryAttempts: Int? = 1
    func adapt(_ urlRequest: URLRequest, for session: any Session) async throws -> URLRequest {
        var request = urlRequest
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct SampleModel: Decodable, Equatable {
    let id: Int
    let name: String
}
