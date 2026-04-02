//
//  ApiClient.swift
//
//  Created by xdmGzDev on 27/3/26.
//

import Foundation

public final class ApiClient: ApiClientProtocol {

    public let session: Session

    public init(session: Session = SessionImpl.shared) {
        self.session = session
    }

    public func asyncRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type
    ) async throws -> T {
        try await asyncRequest(
            endpoint: endpoint,
            responseModel: responseModel,
            requestOptions: RequestOptionsImpl(),
            responseOptions: ResponseOptionsImpl(),
            interceptor: nil
        )
    }

    public func asyncRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions,
        interceptor: (any RequestInterceptor)?
    ) async throws -> T {
        try await executeWithRetry(
            endpoint: endpoint,
            responseModel: responseModel,
            requestOptions: requestOptions,
            responseOptions: responseOptions,
            interceptor: interceptor
        )
    }
}

private extension ApiClient {
    
    func executeWithRetry<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions,
        interceptor: (any RequestInterceptor)?
    ) async throws -> T {
        var attemptCount = 0
        var lastError: Error = ApiError(customError: .unknown)

        let maxRetryAttempts = interceptor?.maxRetryAttempts ?? 1
        while attemptCount < maxRetryAttempts {
            attemptCount += 1
            do {
                let (result, _) = try await performRequest(
                    endpoint: endpoint,
                    responseModel: responseModel,
                    requestOptions: requestOptions,
                    responseOptions: responseOptions,
                    interceptor: interceptor
                )
                return result
            } catch let apiError as ApiError {
                debugPrint("‼️", apiError)
                lastError = apiError

                guard let interceptor else { throw apiError }

                let originalRequest = try endpoint.asURLRequest()
                let retryResult = try await interceptor.retry(originalRequest, for: session, dueTo: apiError)

                switch retryResult {
                case .retry:
                    continue
                case let .retryWithDelay(delay):
                    try await Task.sleep(for: .seconds(delay))
                    continue
                case .doNotRetry:
                    throw apiError
                case let .doNotRetryWithError(overrideError):
                    throw overrideError
                }
            } catch {
                debugPrint("‼️", error)
                throw ApiError(customError: .unknown, originalError: error)
            }
        }

        throw lastError
    }

    func performRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions,
        interceptor: (any RequestInterceptor)?
    ) async throws -> (result: T, adaptedRequest: URLRequest) {
        var request = try endpoint.asURLRequest()
        update(request: &request, options: requestOptions)

        if let interceptor {
            request = try await interceptor.adapt(request, for: session)
        }

        logRequest(request: request, with: requestOptions)

        let (data, response) = try await session.data(for: request)

        logResponse(response: response, data: data, with: responseOptions)
        try validate(response: response, with: responseOptions)
        let decoded: T = try decodeResponse(data: data, using: responseOptions.decoder)
        logDecodedResponse(data: decoded)

        return (decoded, request)
    }

    func update(request: inout URLRequest, options: RequestOptions) {
        request.addAcceptMIMEType(mime: options.mimeType)
    }

    func validate(response: URLResponse?, with options: ResponseOptions) throws {
        try validate(response: response, statusCodes: options.successStatusCodeRange)
        try validate(response: response, mimeTypes: options.mimeTypes)
    }

    func validate(response: URLResponse?, statusCodes: ClosedRange<Int>?) throws {
        guard let allowlist = statusCodes else { return }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError(customError: .invalidResponse)
        }

        if !allowlist.contains(httpResponse.statusCode) {
            var error = ApiError(statusCode: httpResponse.statusCode, customError: .statusCodeNotAllowed)
            if httpResponse.statusCode == KnownError.StatusCode.unauthorized.rawValue {
                error = ApiError(statusCode: httpResponse.statusCode, customError: .unauthorized)
            }

            if httpResponse.statusCode == KnownError.StatusCode.forbiden.rawValue {
                error = ApiError(statusCode: httpResponse.statusCode, customError: .forbiden)
            }

            throw error
        }
    }

    func validate(response: URLResponse?, mimeTypes: [CoreHTTPMimeType]?) throws {
        guard let allowlist = mimeTypes else { return }

        guard let mimeTypeResponse = response?.mimeType else {
            throw ApiError(customError: .invalidResponse)
        }

        let found = !allowlist.filter { $0.rawValue == mimeTypeResponse }.isEmpty
        guard found else {
            throw ApiError(customError: .mimeTypeNotValid)
        }
    }

    func decodeResponse<T: Decodable>(data: Data, using decoder: DataDecoder) throws -> T {
        guard !data.isEmpty else {
            throw ApiError(customError: .responseContentDataUnavailable)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ApiError(customError: .decodingData, originalError: error)
        }
    }

    func logRequest(request: URLRequest, with options: RequestOptions) {
        debugPrint("🛜 \(Self.self) Request info:")
        debugPrint("⬆️ options: \(options)")
        debugPrint("⬆️ method: \(request.httpMethod ?? "")")
        debugPrint("⬆️ url: \(request.url?.absoluteString ?? "")")
        debugPrint("⬆️ headers: \(request.allHTTPHeaderFields ?? [:])")
        debugPrint("⬆️ body: \(request.httpBody?.jsonObject ?? [:])")
        debugPrint("⬆️ END Request info")
    }

    func logResponse(response: URLResponse?, data: Data, with options: ResponseOptions) {
        debugPrint("🛜 \(Self.self) Response info:")
        debugPrint("⬇️ options: \(options)")
        guard let httpResponse = response as? HTTPURLResponse else {
            debugPrint("⬇️ description not valid")
            return
        }
        debugPrint("⬇️ status code: \(httpResponse.statusCode)")
        debugPrint("⬇️ MIME type: \(httpResponse.mimeType ?? "")")
        debugPrint("⬇️ Body: \(data.jsonString ?? "")")
        debugPrint("⬇️ END Response info")
    }

    func logDecodedResponse<T: Decodable>(data: T) {
        debugPrint("🛜 \(Self.self) Decoded Response:")
        debugPrint("📨 description: \(data) \n")
        debugPrint("📨 END Decoded Response")
    }
}

private extension URLRequest {
    mutating func addAcceptMIMEType(mime: CoreHTTPMimeType?) {
        guard let value = mime?.rawValue, !value.isEmpty else { return }
        addValue(value, forHTTPHeaderField: CoreHTTP.HeaderKey.accept.rawValue)
    }
}

private extension Data {
    var jsonObject: [String: Any]? {
        (try? JSONSerialization.jsonObject(with: self, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    var jsonString: String? { String(data: self, encoding: .utf8) }
}
