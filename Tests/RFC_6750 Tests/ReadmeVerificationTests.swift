//
//  ReadmeVerificationTests.swift
//  swift-rfc-6750
//
//  Verifies that README code examples actually work
//

import Foundation
import RFC_6750
import Testing

@Suite("README Verification")
struct ReadmeVerificationTests {

    @Test("README Line 47-56: Creating Bearer Tokens")
    func creatingBearerTokens() throws {
        // Create a Bearer token
        let bearer = try RFC_6750.Bearer(token: "mF_9.B5f-4.1JqM")

        // Use in Authorization header (recommended method)
        let headerValue = bearer.authorizationHeaderValue()

        #expect(headerValue == "Bearer mF_9.B5f-4.1JqM")
    }

    @Test("README Line 60-73: Parsing Bearer Tokens from Requests")
    func parsingBearerTokens() throws {
        // Parse from Authorization header
        let authHeader = "Bearer mF_9.B5f-4.1JqM"
        let bearer = try RFC_6750.Bearer.parse(from: authHeader)
        #expect(bearer.token == "mF_9.B5f-4.1JqM")

        // Parse from form parameters
        let formParams = ["access_token": "mF_9.B5f-4.1JqM"]
        let bearerFromForm = try RFC_6750.Bearer.parse(fromFormParameters: formParams)
        #expect(bearerFromForm.token == "mF_9.B5f-4.1JqM")

        // Parse from query parameters
        let queryItems = [URLQueryItem(name: "access_token", value: "mF_9.B5f-4.1JqM")]
        let bearerFromQuery = try RFC_6750.Bearer.parse(fromQueryItems: queryItems)
        #expect(bearerFromQuery.token == "mF_9.B5f-4.1JqM")
    }

    @Test("README Line 77-89: Generating WWW-Authenticate Challenges")
    func generatingChallenges() throws {
        // Create a challenge with error information
        let challenge = RFC_6750.Bearer.Challenge(
            realm: "example",
            scope: "read write",
            error: .invalidToken,
            errorDescription: "The access token expired"
        )

        // Generate WWW-Authenticate header value
        let headerValue = challenge.wwwAuthenticateHeaderValue()

        #expect(headerValue.contains("Bearer"))
        #expect(headerValue.contains("realm=\"example\""))
        #expect(headerValue.contains("scope=\"read write\""))
        #expect(headerValue.contains("error=\"invalid_token\""))
        #expect(headerValue.contains("error_description=\"The access token expired\""))
    }

    @Test("README Line 93-99: Parsing WWW-Authenticate Challenges")
    func parsingChallenges() throws {
        let wwwAuth = "Bearer, realm=\"example\", error=\"invalid_token\""
        let challenge = try RFC_6750.Bearer.Challenge.parse(from: wwwAuth)

        #expect(challenge.realm == "example")
        #expect(challenge.error == .invalidToken)
    }

    @Test("README Line 103-122: Error Handling")
    func errorHandling() throws {
        // Token validation errors
        do {
            let _ = try RFC_6750.Bearer(token: "")
            Issue.record("Should have thrown invalidToken error")
        } catch RFC_6750.Bearer.Error.invalidToken(let message) {
            #expect(message.contains("empty"))
        }

        // Parse errors
        do {
            let _ = try RFC_6750.Bearer.parse(from: "Invalid header")
            Issue.record("Should have thrown invalidRequest error")
        } catch RFC_6750.Bearer.Error.invalidRequest(let message) {
            #expect(message.contains("Bearer"))
        }

        // Using error codes
        let error = RFC_6750.Bearer.Error.insufficientScope("Requires admin access")
        #expect(error.errorCode == .insufficientScope)
        #expect(error.localizedDescription.contains("Insufficient scope"))
        #expect(error.localizedDescription.contains("Requires admin access"))
    }

    @Test("README Line 128-133: Bearer Token Type")
    func bearerTokenType() throws {
        let bearer = try RFC_6750.Bearer(token: "test_token")
        #expect(bearer.token == "test_token")

        // Test that it's Codable
        let encoder = JSONEncoder()
        let data = try encoder.encode(bearer)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RFC_6750.Bearer.self, from: data)
        #expect(decoded.token == bearer.token)

        // Test that it's Hashable
        let set: Set<RFC_6750.Bearer> = [bearer]
        #expect(set.contains(bearer))
    }

    @Test("README Line 137-147: Transmission Methods")
    func transmissionMethods() throws {
        let bearer = try RFC_6750.Bearer(token: "test_token")

        // Authorization header (recommended)
        let authHeader = bearer.authorizationHeaderValue()
        #expect(authHeader == "Bearer test_token")

        // Form parameters
        let formParam = bearer.formParameter()
        #expect(formParam.name == "access_token")
        #expect(formParam.value == "test_token")

        // Query parameters
        let queryParam = bearer.queryParameter()
        #expect(queryParam.name == "access_token")
        #expect(queryParam.value == "test_token")
    }

    @Test("README Line 151-161: Challenge Type")
    func challengeType() throws {
        let challenge = RFC_6750.Bearer.Challenge(
            realm: "test",
            scope: "read",
            error: .insufficientScope,
            errorDescription: "Not enough privileges"
        )

        let header = challenge.wwwAuthenticateHeaderValue()
        #expect(header.contains("Bearer"))

        // Test parsing
        let parsed = try RFC_6750.Bearer.Challenge.parse(from: header)
        #expect(parsed.realm == "test")
        #expect(parsed.scope == "read")
        #expect(parsed.error == .insufficientScope)
    }

    @Test("README Line 165-171: Error Codes")
    func errorCodes() throws {
        #expect(RFC_6750.Bearer.ErrorCode.invalidRequest.rawValue == "invalid_request")
        #expect(RFC_6750.Bearer.ErrorCode.invalidToken.rawValue == "invalid_token")
        #expect(RFC_6750.Bearer.ErrorCode.insufficientScope.rawValue == "insufficient_scope")

        // Test that all cases exist
        let allCases = RFC_6750.Bearer.ErrorCode.allCases
        #expect(allCases.count == 3)
    }

    @Test("README Line 175-184: Error Type")
    func errorType() throws {
        let invalidRequest = RFC_6750.Bearer.Error.invalidRequest("test")
        #expect(invalidRequest.errorCode == .invalidRequest)
        #expect(invalidRequest.localizedDescription.contains("Invalid request"))

        let invalidToken = RFC_6750.Bearer.Error.invalidToken("test")
        #expect(invalidToken.errorCode == .invalidToken)
        #expect(invalidToken.localizedDescription.contains("Invalid token"))

        let insufficientScope = RFC_6750.Bearer.Error.insufficientScope("test")
        #expect(insufficientScope.errorCode == .insufficientScope)
        #expect(insufficientScope.localizedDescription.contains("Insufficient scope"))
    }
}
