//
//  RetryLogicTests.swift
//  CoreNetwork
//
//  Created by xdmGzDev on 28/3/26.
//

import Foundation
import Testing
@testable import CoreNetwork

@Suite(.tags(.retryLogic))
struct RetryLogicTests {

    @Test func withoutInterceptorThrowsImmediatelyAfterFirstFailure() async throws {
        let session = MockSession()
        let json = "{}".data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 401))]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self,
                requestOptions: RequestOptionsImpl(),
                responseOptions: ResponseOptionsImpl(),
                interceptor: nil
            )
            Issue.record("Expected error to be thrown.")
        } catch is ApiError {
            #expect(session.callCount == 1, "No interceptor means exactly one attempt")
        }
    }

    @Test func doNotRetryInterceptorStopsAfterFirstFailure() async throws {
        let session = MockSession()
        let json = "{}".data(using: .utf8)!
        let failResponse = session.makeHTTPResponse(statusCode: 500)
        session.responses = [(json, failResponse), (json, failResponse), (json, failResponse)]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self,
                requestOptions: RequestOptionsImpl(),
                responseOptions: ResponseOptionsImpl(),
                interceptor: DoNotRetryInterceptor()
            )
            Issue.record("Expected error to be thrown.")
        } catch is ApiError {
            #expect(session.callCount == 1, "doNotRetry should stop after the first failure")
        }
    }

    @Test func retryInterceptorExhaustsMaxAttempts() async throws {
        let session = MockSession()
        let json = "{}".data(using: .utf8)!
        let failResponse = session.makeHTTPResponse(statusCode: 500)
        session.responses = [(json, failResponse), (json, failResponse), (json, failResponse)]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self,
                requestOptions: RequestOptionsImpl(),
                responseOptions: ResponseOptionsImpl(),
                interceptor: AlwaysRetryInterceptor()
            )
            Issue.record("Expected error after exhausting retries.")
        } catch is ApiError {
            #expect(session.callCount == 3, "Should attempt maxRetryAttempts (3) times before giving up")
        }
    }

    @Test func doNotRetryWithErrorInterceptorThrowsOverrideError() async throws {
        let session = MockSession()
        let json = "{}".data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 401))]
        let client = ApiClient(session: session)
        do {
            let _: SampleModel = try await client.asyncRequest(
                endpoint: MockEndpoint(),
                responseModel: SampleModel.self,
                requestOptions: RequestOptionsImpl(),
                responseOptions: ResponseOptionsImpl(),
                interceptor: OverrideErrorInterceptor()
            )
            Issue.record("Expected override error to be thrown.")
        } catch is OverrideErrorInterceptor.OverrideError {
            // success — correct error type was propagated
        } catch {
            Issue.record("Wrong error type thrown: \(error)")
        }
    }

    @Test func retryInterceptorSucceedsOnSecondAttempt() async throws {
        let session = MockSession()
        let failJson = "{}".data(using: .utf8)!
        let successJson = #"{"id": 42, "name": "Retried"}"#.data(using: .utf8)!
        session.responses = [
            (failJson, session.makeHTTPResponse(statusCode: 500)),
            (successJson, session.makeHTTPResponse(statusCode: 200))
        ]

        struct RetryOnceInterceptor: RequestInterceptor {
            var maxRetryAttempts: Int? = 2
            func retry(_ request: URLRequest, for session: any Session, dueTo error: Error) async throws -> RetryResult {
                .retry
            }
        }

        let client = ApiClient(session: session)
        let result: SampleModel = try await client.asyncRequest(
            endpoint: MockEndpoint(),
            responseModel: SampleModel.self,
            requestOptions: RequestOptionsImpl(),
            responseOptions: ResponseOptionsImpl(),
            interceptor: RetryOnceInterceptor()
        )
        #expect(result == SampleModel(id: 42, name: "Retried"))
        #expect(session.callCount == 2, "Should succeed on the second attempt")
    }

    @Test func interceptorAdaptsRequestBeforeSending() async throws {
        let session = MockSession()
        let json = #"{"id": 1, "name": "Test"}"#.data(using: .utf8)!
        session.responses = [(json, session.makeHTTPResponse(statusCode: 200))]
        let client = ApiClient(session: session)

        let _: SampleModel = try await client.asyncRequest(
            endpoint: MockEndpoint(),
            responseModel: SampleModel.self,
            requestOptions: RequestOptionsImpl(),
            responseOptions: ResponseOptionsImpl(),
            interceptor: TokenAddingInterceptor(token: "secret")
        )

        let sentRequest = try #require(session.lastRequest)
        #expect(sentRequest.value(forHTTPHeaderField: "Authorization") == "Bearer secret")
    }
}

@Suite(.tags(.retryLogic))
struct RetryResultTests {

    @Test(arguments: [RetryResult.retry, RetryResult.retryWithDelay(1.0)])
    func retryRequiredIsTrueForRetryingCases(result: RetryResult) {
        #expect(result.retryRequired == true)
    }

    @Test func retryRequiredIsFalseForDoNotRetry() {
        #expect(RetryResult.doNotRetry.retryRequired == false)
    }

    @Test func delayIsNilForNonDelayedCases() {
        #expect(RetryResult.retry.delay == nil)
        #expect(RetryResult.doNotRetry.delay == nil)
    }

    @Test func delayValueIsReturnedForRetryWithDelay() {
        #expect(RetryResult.retryWithDelay(5.0).delay == 5.0)
    }

    @Test func errorIsNilForNonErrorCases() {
        #expect(RetryResult.retry.error == nil)
        #expect(RetryResult.doNotRetry.error == nil)
        #expect(RetryResult.retryWithDelay(1.0).error == nil)
    }

    @Test func errorIsReturnedForDoNotRetryWithError() {
        struct TestError: Error {}
        let result = RetryResult.doNotRetryWithError(TestError())
        #expect(result.error != nil)
    }
}
