//
//  ApiClientProtocol.swift
//
//  Created by xdmGzDev on 27/3/26.
//

import Foundation

public protocol ApiClientProtocol: Sendable {
    var session: Session { get }

    func asyncRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type
    ) async throws -> T

    func asyncRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions,
        interceptor: (any RequestInterceptor)?
    ) async throws -> T
}

public extension ApiClientProtocol {

    func asyncRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type
    ) async throws -> T {
        try await asyncRequest(
            endpoint: endpoint,
            responseModel: responseModel
        )
    }

    func asyncRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions,
        interceptor: (any RequestInterceptor)?
    ) async throws -> T {
        try await asyncRequest(
            endpoint: endpoint,
            responseModel: responseModel,
            requestOptions: requestOptions,
            responseOptions: responseOptions,
            interceptor: interceptor
        )
    }
}
