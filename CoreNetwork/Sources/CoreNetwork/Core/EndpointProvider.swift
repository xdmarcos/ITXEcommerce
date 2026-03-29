//
//  EndpointProvider.swift
//
//  Created by xdmGzDev on 27/3/26.
//

import Foundation

public protocol EndpointProvider: Sendable {

    var scheme: CoreHTTPScheme { get }
    var baseURL: String { get }
    var path: String { get }
    var method: CoreHTTPMethod { get }
    var authorization: CoreHTTPAuthorizationMethod? { get }
    var headers: [CoreHTTPHeaderKey: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: (any Encodable & Sendable)? { get }
    var mockFile: String? { get }
    var multipart: Multipart? { get }
}
