//
//  ApiClientTests.swift
//  CoreNetwork
//
//  Created by xdmGzDev on 28/3/26.
//

import Foundation
import Testing
@testable import CoreNetwork

@Suite(.tags(.networking))
struct ApiClientTests {

    let session = MockSession()

    @Test func successfulRequestDecodesModel() async throws {
        let json = #"{"id": 1, "name": "Test"}"#.data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 200))]
        let client = ApiClient(session: session)
        let result: SampleModel = try await client.asyncRequest(
            endpoint: MockEndpoint(),
            responseModel: SampleModel.self
        )
        #expect(result == SampleModel(id: 1, name: "Test"))
    }

    @Test(.tags(.errorHandling))
    func emptyResponseDataThrowsContentUnavailableError() async throws {
        session.responses = [(Data(), session.makeHTTPResponse(statusCode: 200))]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self
            )
            Issue.record("Expected responseContentDataUnavailable error to be thrown.")
        } catch let error as ApiError {
            #expect(error.errorCode == KnownError.ErrorCode.responseContentDataUnavailable.code)
        }
    }

    @Test(.tags(.errorHandling))
    func malformedJSONThrowsDecodingError() async throws {
        let badJson = "not-json".data(using: .utf8)!
        session.responses = [(badJson, session.makeHTTPResponse(statusCode: 200))]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self
            )
            Issue.record("Expected decodingData error to be thrown.")
        } catch let error as ApiError {
            #expect(error.errorCode == KnownError.ErrorCode.decodingData.code)
        }
    }

    @Test(.tags(.errorHandling))
    func unauthorizedStatusCodeThrowsUnauthorizedError() async throws {
        let json = "{}".data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 401))]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self
            )
            Issue.record("Expected unauthorized error to be thrown.")
        } catch let error as ApiError {
            #expect(error.errorCode == KnownError.ErrorCode.unauthorized.code)
            #expect(error.statusCode == 401)
        }
    }

    @Test(.tags(.errorHandling))
    func forbiddenStatusCodeThrowsForbiddenError() async throws {
        let json = "{}".data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 403))]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self
            )
            Issue.record("Expected forbidden error to be thrown.")
        } catch let error as ApiError {
            #expect(error.errorCode == KnownError.ErrorCode.forbiden.code)
            #expect(error.statusCode == 403)
        }
    }

    @Test(.tags(.errorHandling))
    func serverErrorStatusCodeThrowsStatusCodeNotAllowedError() async throws {
        let json = "{}".data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 500))]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self
            )
            Issue.record("Expected statusCodeNotAllowed error to be thrown.")
        } catch let error as ApiError {
            #expect(error.errorCode == KnownError.ErrorCode.statusCodeNotAllowed.code)
            #expect(error.statusCode == 500)
        }
    }

    @Test(.tags(.errorHandling))
    func unexpectedMimeTypeThrowsMimeTypeNotValidError() async throws {
        let json = #"{"id":1,"name":"Test"}"#.data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 200, mimeType: "text/html"))]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self,
                requestOptions: RequestOptionsImpl(),
                responseOptions: ResponseOptionsImpl(mimeTypes: [.json]),
                interceptor: nil
            )
            Issue.record("Expected mimeTypeNotValid error to be thrown.")
        } catch let error as ApiError {
            #expect(error.errorCode == KnownError.ErrorCode.mimeTypeNotValid.code)
        }
    }

    @Test(.tags(.errorHandling))
    func networkErrorIsWrappedInApiUnknownError() async throws {
        struct NetworkError: Error {}
        session.error = NetworkError()
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self
            )
            Issue.record("Expected unknown API error to be thrown.")
        } catch let error as ApiError {
            #expect(error.errorCode == KnownError.ErrorCode.unknown.code)
        }
    }

    @Test func acceptHeaderIsSetFromRequestMimeType() async throws {
        let json = #"{"id":1,"name":"Test"}"#.data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 200))]
        let client = ApiClient(session: session)
        let _: SampleModel = try await client.asyncRequest(
            endpoint: MockEndpoint(),
            responseModel: SampleModel.self,
            requestOptions: RequestOptionsImpl(mimeType: .json),
            responseOptions: ResponseOptionsImpl(),
            interceptor: nil
        )
        let sentRequest = try #require(session.lastRequest)
        #expect(sentRequest.value(forHTTPHeaderField: "Accept") == CoreHTTPMimeType.json.rawValue)
    }
}
