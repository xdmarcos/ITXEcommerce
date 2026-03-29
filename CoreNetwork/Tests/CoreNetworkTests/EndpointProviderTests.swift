//
//  EndpointProviderTests.swift
//  CoreNetwork
//
//  Created by xdmGzDev on 28/3/26.
//

import Foundation
import Testing
@testable import CoreNetwork

@Suite(.tags(.endpointBuilder))
struct EndpointProviderTests {

    @Test func basicGetRequestBuildsCorrectURL() throws {
        let endpoint = MockEndpoint()
        let request = try endpoint.asURLRequest()
        let url = try #require(request.url)
        #expect(url.scheme == "https")
        #expect(url.host == "example.com")
        #expect(url.path == "/api/test")
        #expect(request.httpMethod == "GET")
    }

    @Test func postMethodIsSetOnRequest() throws {
        var endpoint = MockEndpoint()
        endpoint.method = .post
        let request = try endpoint.asURLRequest()
        #expect(request.httpMethod == "POST")
    }

    @Test func queryItemsAreAppendedToURL() throws {
        var endpoint = MockEndpoint()
        endpoint.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "10")
        ]
        let request = try endpoint.asURLRequest()
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = try #require(components.queryItems)
        #expect(queryItems.contains(URLQueryItem(name: "page", value: "1")))
        #expect(queryItems.contains(URLQueryItem(name: "limit", value: "10")))
    }

    @Test func customHeadersAreSetOnRequest() throws {
        var endpoint = MockEndpoint()
        endpoint.headers = [.contentType: "application/json"]
        let request = try endpoint.asURLRequest()
        #expect(request.allHTTPHeaderFields?[CoreHTTPHeaderKey.contentType.rawValue] == "application/json")
    }

    @Test func bearerAuthorizationIsAddedToRequest() throws {
        var endpoint = MockEndpoint()
        endpoint.authorization = .bearer(token: "abc123")
        let request = try endpoint.asURLRequest()
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer abc123")
    }

    @Test func basicAuthorizationIsAddedToRequest() throws {
        var endpoint = MockEndpoint()
        endpoint.authorization = .basic(token: "dXNlcjpwYXNz")
        let request = try endpoint.asURLRequest()
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Basic dXNlcjpwYXNz")
    }

    @Test func bodyIsEncodedAsJSONForPostRequest() throws {
        struct PostBody: Encodable, Sendable, Decodable, Equatable {
            let title: String
        }
        struct PostEndpoint: EndpointProvider {
            var scheme: CoreHTTPScheme { .https }
            var baseURL: String { "example.com" }
            var path: String { "/api/items" }
            var method: CoreHTTPMethod { .post }
            var authorization: CoreHTTPAuthorizationMethod? { nil }
            var headers: [CoreHTTPHeaderKey: String]? { nil }
            var queryItems: [URLQueryItem]? { nil }
            var body: (any Encodable & Sendable)? { PostBody(title: "Hello") }
            var mockFile: String? { nil }
            var multipart: Multipart? { nil }
        }
        let request = try PostEndpoint().asURLRequest()
        let bodyData = try #require(request.httpBody)
        let decoded = try JSONDecoder().decode(PostBody.self, from: bodyData)
        #expect(decoded == PostBody(title: "Hello"))
    }

    @Test func invalidPathThrowsUrlComponentsError() {
        var endpoint = MockEndpoint()
        endpoint.path = "missing-leading-slash"
        #expect(throws: ApiError.self) {
            try endpoint.asURLRequest()
        }
    }
}
