import Testing
import Foundation
@testable import CoreNetwork

extension Tag {
    @Tag static var networking: Self
    @Tag static var endpointBuilder: Self
    @Tag static var retryLogic: Self
    @Tag static var errorHandling: Self
}

struct ApiErrorTests {

    @Test func unauthorizedErrorCodeNumberIs401() {
        let error = ApiError(customError: .unauthorized)
        #expect(error.errorCodeNumber == "401")
    }

    @Test func unknownErrorCodeNumberIs0() {
        let error = ApiError(customError: .unknown)
        #expect(error.errorCodeNumber == "0")
    }

    @Test func decodingDataErrorCodeNumberIs1() {
        let error = ApiError(customError: .decodingData)
        #expect(error.errorCodeNumber == "1")
    }

    @Test func apiErrorIsDecodable() throws {
        let json = #"{"errorCode": "ERROR-1", "message": "Test message"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(ApiError.self, from: json)
        #expect(decoded.errorCode == "ERROR-1")
        #expect(decoded.message == "Test message")
        #expect(decoded.statusCode == 0)
        #expect(decoded.originalError == nil)
    }

    @Test func debugDescriptionContainsStatusCodeAndErrorCode() {
        let error = ApiError(statusCode: 404, customError: .statusCodeNotAllowed)
        #expect(error.debugDescription.contains("404"))
        #expect(error.debugDescription.contains(KnownError.ErrorCode.statusCodeNotAllowed.code))
    }

    @Test func errorInitWithApiErrorCopiesCodeAndMessage() {
        let original = ApiError(statusCode: 401, customError: .unauthorized)
        let derived = ApiError(statusCode: 401, apiError: original)
        #expect(derived.errorCode == original.errorCode)
        #expect(derived.message == original.message)
    }
}

struct KnownErrorTests {

    @Test(arguments: [
        (KnownError.ErrorCode.unknown, "ERROR-0"),
        (KnownError.ErrorCode.decodingData, "ERROR-1"),
        (KnownError.ErrorCode.encodingBody, "ERROR-2"),
        (KnownError.ErrorCode.unauthorized, "ERROR-401"),
        (KnownError.ErrorCode.forbiden, "ERROR-403"),
        (KnownError.ErrorCode.statusCodeNotAllowed, "ERROR-6"),
        (KnownError.ErrorCode.mimeTypeNotValid, "ERROR-7"),
        (KnownError.ErrorCode.responseContentDataUnavailable, "ERROR-8"),
    ])
    func errorCodeHasExpectedCodeString(errorCode: KnownError.ErrorCode, expected: String) {
        #expect(errorCode.code == expected, "Expected \(errorCode) to have code \(expected)")
    }

    @Test func knownErrorMessagesAreNonEmpty() {
        let codes: [KnownError.ErrorCode] = [
            .unknown, .decodingData, .encodingBody, .forbiden, .invalidResponse,
            .unauthorized, .urlComponents, .statusCodeNotAllowed, .mimeTypeNotValid,
            .responseContentDataUnavailable
        ]
        for code in codes {
            #expect(code.message.isEmpty == false, "\(code) should have a non-empty message")
        }
    }

    @Test func notFoundStatusCodeDescriptionContains404() {
        let status = KnownError.StatusCode.notFound
        #expect(status.debugDescription.contains("404"))
        #expect(status.debugDescription.contains("Not Found"))
    }

    @Test func unauthorizedStatusCodeDescriptionContains401() {
        #expect(KnownError.StatusCode.unauthorized.debugDescription.contains("401"))
    }

    @Test func internalServerErrorDescriptionContains500() {
        #expect(KnownError.StatusCode.internalServerError.debugDescription.contains("500"))
    }
}

struct CoreHTTPAuthorizationTests {

    @Test func bearerAuthorizationValueHasCorrectFormat() {
        let method = CoreHTTP.AuthorizationMethod.bearer(token: "mytoken")
        #expect(method.value == "Bearer mytoken")
    }

    @Test func basicAuthorizationValueHasCorrectFormat() {
        let method = CoreHTTP.AuthorizationMethod.basic(token: "dXNlcjpwYXNz")
        #expect(method.value == "Basic dXNlcjpwYXNz")
    }

    @Test func digestAuthorizationValueHasCorrectFormat() {
        let method = CoreHTTP.AuthorizationMethod.digest(token: "digesttoken")
        #expect(method.value == "Digest digesttoken")
    }

    @Test func awsAuthorizationValueStartsWithAWSPrefix() {
        let method = CoreHTTP.AuthorizationMethod.aws(token: "sigv4payload")
        #expect(method.value.hasPrefix("AWS4-HMAC-SHA256"))
        #expect(method.value.contains("sigv4payload"))
    }
}

struct MultipartTests {

    @Test func headerValueContainsMultipartFormDataAndBoundary() {
        var multipart = Multipart()
        multipart.append(fileString: "hello", withName: "field")
        #expect(multipart.headerValue.contains("multipart/form-data"))
        #expect(multipart.headerValue.contains("boundary="))
    }

    @Test func httpBodyContainsFieldNameAndValue() {
        var multipart = Multipart()
        multipart.append(fileString: "myvalue", withName: "myfield")
        let bodyString = String(data: multipart.httpBody, encoding: .utf8) ?? ""
        #expect(bodyString.contains("name=\"myfield\""))
        #expect(bodyString.contains("myvalue"))
    }

    @Test func httpBodyContainsEndBoundaryMarker() {
        var multipart = Multipart()
        multipart.append(fileString: "data", withName: "field")
        let bodyString = String(data: multipart.httpBody, encoding: .utf8) ?? ""
        #expect(bodyString.hasSuffix("--"))
    }

    @Test func lengthMatchesHttpBodyByteCount() {
        var multipart = Multipart()
        multipart.append(fileString: "some data", withName: "field")
        #expect(multipart.length == UInt64(multipart.httpBody.count))
    }

    @Test func appendingFileDataIncludesMimeTypeAndFileName() {
        var multipart = Multipart()
        let data = "content".data(using: .utf8)!
        multipart.append(fileData: data, withName: "upload", fileName: "test.txt", mimeType: .plain)
        let bodyString = String(data: multipart.httpBody, encoding: .utf8) ?? ""
        #expect(bodyString.contains("text/plain"))
        #expect(bodyString.contains("test.txt"))
        #expect(bodyString.contains("content"))
    }

    @Test func multipleFieldsAllAppearInBody() {
        var multipart = Multipart()
        multipart.append(fileString: "value1", withName: "field1")
        multipart.append(fileString: "value2", withName: "field2")
        let bodyString = String(data: multipart.httpBody, encoding: .utf8) ?? ""
        #expect(bodyString.contains("field1"))
        #expect(bodyString.contains("value1"))
        #expect(bodyString.contains("field2"))
        #expect(bodyString.contains("value2"))
    }
}
