//
//  RequestInterceptor.swift
//
//  Created by xdmGzDev on 27/3/26.
//

import Foundation

/// Type that provides both `RequestAdapter` and `RequestRetrier` functionality.
public protocol RequestInterceptor: RequestAdapter, RequestRetrier {}

extension RequestInterceptor {

    public func adapt(_ urlRequest: URLRequest, for session: Session) async throws -> URLRequest {
        urlRequest
    }

    public func retry(
        _ request: URLRequest,
        for session: Session,
        dueTo error: Error
    ) async throws -> RetryResult {
        .doNotRetry
    }

    public var maxRetryAttempts: Int? { nil }
}

@frozen
public enum RetryResult: Sendable {
    case retry
    case retryWithDelay(TimeInterval)
    case doNotRetry
    case doNotRetryWithError(Error)
}

extension RetryResult {
    var retryRequired: Bool {
        switch self {
        case .retry, .retryWithDelay: return true
        default: return false
        }
    }

    var delay: TimeInterval? {
        switch self {
        case let .retryWithDelay(delay): return delay
        default: return nil
        }
    }

    var error: Error? {
        guard case let .doNotRetryWithError(error) = self else { return nil }
        return error
    }
}

public protocol RequestAdapter: Sendable {
    /// Inspects and optionally adapts the specified `URLRequest`.
    func adapt(_ urlRequest: URLRequest, for session: Session) async throws -> URLRequest
}

/// A type that determines whether a failed request should be retried.
public protocol RequestRetrier: Sendable {
    var maxRetryAttempts: Int? { get }
    /// Determines whether the failed `URLRequest` should be retried.
    func retry(_ request: URLRequest, for session: Session, dueTo error: Error) async throws -> RetryResult
}
