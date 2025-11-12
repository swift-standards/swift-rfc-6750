//
//  RFC_6750 Tests.swift
//  RFC_6750 Tests
//
//  Created by Generated on 2025-07-27.
//

import Testing
import Foundation
@testable import RFC_6750

@Suite("RFC 6750 Tests")
struct RFC_6750_Tests {

    @Test("Bearer token creation and validation")
    func testBearerTokenCreation() throws {
        let bearer = try RFC_6750.Bearer(token: "mF_9.B5f-4.1JqM")
        #expect(bearer.token == "mF_9.B5f-4.1JqM")
        
        // Test empty token throws error
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer(token: "")
        }
        
        // Test whitespace-only token throws error
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer(token: "   ")
        }
        
        // Test token with whitespace throws error
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer(token: "token with spaces")
        }
        
        // Test token with non-ASCII characters throws error
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer(token: "tökén")
        }
    }
    
    @Test("Bearer token Authorization header method")
    func testAuthorizationHeaderMethod() throws {
        let bearer = try RFC_6750.Bearer(token: "mF_9.B5f-4.1JqM")
        let headerValue = bearer.authorizationHeaderValue()
        #expect(headerValue == "Bearer mF_9.B5f-4.1JqM")
    }
    
    @Test("Bearer token form parameter method")
    func testFormParameterMethod() throws {
        let bearer = try RFC_6750.Bearer(token: "mF_9.B5f-4.1JqM")
        let formParam = bearer.formParameter()
        #expect(formParam.name == "access_token")
        #expect(formParam.value == "mF_9.B5f-4.1JqM")
    }
    
    @Test("Bearer token query parameter method")
    func testQueryParameterMethod() throws {
        let bearer = try RFC_6750.Bearer(token: "mF_9.B5f-4.1JqM")
        let queryParam = bearer.queryParameter()
        #expect(queryParam.name == "access_token")
        #expect(queryParam.value == "mF_9.B5f-4.1JqM")
    }
    
    @Test("Bearer token parsing from Authorization header")
    func testBearerTokenParsingFromHeader() throws {
        let headerValue = "Bearer mF_9.B5f-4.1JqM"
        let bearer = try RFC_6750.Bearer.parse(from: headerValue)
        #expect(bearer.token == "mF_9.B5f-4.1JqM")
        
        // Test with whitespace
        let headerWithSpaces = "  Bearer mF_9.B5f-4.1JqM  "
        let bearerWithSpaces = try RFC_6750.Bearer.parse(from: headerWithSpaces)
        #expect(bearerWithSpaces.token == "mF_9.B5f-4.1JqM")
    }
    
    @Test("Bearer token parsing from Authorization header error cases")
    func testBearerTokenParsingFromHeaderErrors() {
        // Missing "Bearer " prefix
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.parse(from: "Basic mF_9.B5f-4.1JqM")
        }
        
        // Empty token
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.parse(from: "Bearer ")
        }
        
        // Only "Bearer"
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.parse(from: "Bearer")
        }
    }
    
    @Test("Bearer token parsing from form parameters")
    func testBearerTokenParsingFromFormParameters() throws {
        let parameters = ["access_token": "mF_9.B5f-4.1JqM", "other_param": "value"]
        let bearer = try RFC_6750.Bearer.parse(fromFormParameters: parameters)
        #expect(bearer.token == "mF_9.B5f-4.1JqM")
    }
    
    @Test("Bearer token parsing from form parameters error cases")
    func testBearerTokenParsingFromFormParametersErrors() {
        // Missing access_token parameter
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.parse(fromFormParameters: ["other_param": "value"])
        }
        
        // Empty access_token parameter
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.parse(fromFormParameters: ["access_token": ""])
        }
    }
    
    @Test("Bearer token parsing from query items")
    func testBearerTokenParsingFromQueryItems() throws {
        let queryItems = [
            URLQueryItem(name: "access_token", value: "mF_9.B5f-4.1JqM"),
            URLQueryItem(name: "other_param", value: "value")
        ]
        let bearer = try RFC_6750.Bearer.parse(fromQueryItems: queryItems)
        #expect(bearer.token == "mF_9.B5f-4.1JqM")
    }
    
    @Test("Bearer token parsing from query items error cases")
    func testBearerTokenParsingFromQueryItemsErrors() {
        // Missing access_token parameter
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.parse(fromQueryItems: [URLQueryItem(name: "other_param", value: "value")])
        }
        
        // access_token parameter with nil value
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.parse(fromQueryItems: [URLQueryItem(name: "access_token", value: nil)])
        }
        
        // Empty access_token parameter
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.parse(fromQueryItems: [URLQueryItem(name: "access_token", value: "")])
        }
    }
    
    @Test("Bearer Challenge creation")
    func testBearerChallengeCreation() {
        let challenge = RFC_6750.Bearer.Challenge()
        #expect(challenge.realm == nil)
        #expect(challenge.scope == nil)
        #expect(challenge.error == nil)
        #expect(challenge.errorDescription == nil)
        
        let challengeWithParams = RFC_6750.Bearer.Challenge(
            realm: "example.com",
            scope: "read write",
            error: .invalidToken,
            errorDescription: "Token has expired"
        )
        #expect(challengeWithParams.realm == "example.com")
        #expect(challengeWithParams.scope == "read write")
        #expect(challengeWithParams.error == .invalidToken)
        #expect(challengeWithParams.errorDescription == "Token has expired")
    }
    
    @Test("Bearer Challenge WWW-Authenticate header generation")
    func testBearerChallengeHeaderGeneration() {
        let challenge = RFC_6750.Bearer.Challenge()
        let headerValue = challenge.wwwAuthenticateHeaderValue()
        #expect(headerValue == "Bearer")
        
        let challengeWithRealm = RFC_6750.Bearer.Challenge(realm: "example.com")
        let headerValueWithRealm = challengeWithRealm.wwwAuthenticateHeaderValue()
        #expect(headerValueWithRealm == "Bearer, realm=\"example.com\"")
        
        let fullChallenge = RFC_6750.Bearer.Challenge(
            realm: "example.com",
            scope: "read write",
            error: .invalidToken,
            errorDescription: "Token has expired"
        )
        let fullHeaderValue = fullChallenge.wwwAuthenticateHeaderValue()
        #expect(fullHeaderValue == "Bearer, realm=\"example.com\", scope=\"read write\", error=\"invalid_token\", error_description=\"Token has expired\"")
    }
    
    @Test("Bearer Challenge parsing from WWW-Authenticate header")
    func testBearerChallengeParsing() throws {
        let headerValue = "Bearer"
        let challenge = try RFC_6750.Bearer.Challenge.parse(from: headerValue)
        #expect(challenge.realm == nil)
        #expect(challenge.scope == nil)
        #expect(challenge.error == nil)
        #expect(challenge.errorDescription == nil)
        
        let headerValueWithRealm = "Bearer realm=\"example.com\""
        let challengeWithRealm = try RFC_6750.Bearer.Challenge.parse(from: headerValueWithRealm)
        #expect(challengeWithRealm.realm == "example.com")
        
        let fullHeaderValue = "Bearer realm=\"example.com\", scope=\"read write\", error=\"invalid_token\", error_description=\"Token has expired\""
        let fullChallenge = try RFC_6750.Bearer.Challenge.parse(from: fullHeaderValue)
        #expect(fullChallenge.realm == "example.com")
        #expect(fullChallenge.scope == "read write")
        #expect(fullChallenge.error == .invalidToken)
        #expect(fullChallenge.errorDescription == "Token has expired")
    }
    
    @Test("Bearer Challenge parsing with unquoted values")
    func testBearerChallengeParsingUnquoted() throws {
        let headerValue = "Bearer realm=example.com, scope=read"
        let challenge = try RFC_6750.Bearer.Challenge.parse(from: headerValue)
        #expect(challenge.realm == "example.com")
        #expect(challenge.scope == "read")
    }
    
    @Test("Bearer Challenge parsing error cases")
    func testBearerChallengeParsingErrors() {
        // Missing "Bearer" prefix
        #expect(throws: RFC_6750.Bearer.Error.self) {
            try RFC_6750.Bearer.Challenge.parse(from: "Basic realm=\"example.com\"")
        }
    }
    
    @Test("ErrorCode descriptions")
    func testErrorCodeDescriptions() {
        #expect(RFC_6750.Bearer.ErrorCode.invalidRequest.description.contains("missing a required parameter"))
        #expect(RFC_6750.Bearer.ErrorCode.invalidToken.description.contains("expired, revoked, malformed"))
        #expect(RFC_6750.Bearer.ErrorCode.insufficientScope.description.contains("higher privileges"))
    }
    
    @Test("Bearer Error localized descriptions")
    func testBearerErrorDescriptions() {
        let requestError = RFC_6750.Bearer.Error.invalidRequest("test message")
        #expect(requestError.localizedDescription == "Invalid request: test message")
        #expect(requestError.errorCode == .invalidRequest)
        
        let tokenError = RFC_6750.Bearer.Error.invalidToken("test message")
        #expect(tokenError.localizedDescription == "Invalid token: test message")
        #expect(tokenError.errorCode == .invalidToken)
        
        let scopeError = RFC_6750.Bearer.Error.insufficientScope("test message")
        #expect(scopeError.localizedDescription == "Insufficient scope: test message")
        #expect(scopeError.errorCode == .insufficientScope)
    }
    
    @Test("Edge case: token with special characters")
    func testTokenWithSpecialCharacters() throws {
        let bearer = try RFC_6750.Bearer(token: "mF_9.B5f-4.1JqM~!@#$%^&*()+={}[]|\\:;\"'<>?")
        #expect(bearer.token == "mF_9.B5f-4.1JqM~!@#$%^&*()+={}[]|\\:;\"'<>?")
        
        // Test round-trip through Authorization header
        let headerValue = bearer.authorizationHeaderValue()
        let parsed = try RFC_6750.Bearer.parse(from: headerValue)
        #expect(parsed.token == bearer.token)
    }
    
    @Test("Edge case: very long token")
    func testVeryLongToken() throws {
        let longToken = String(repeating: "a", count: 1000)
        let bearer = try RFC_6750.Bearer(token: longToken)
        #expect(bearer.token == longToken)
        
        // Test round-trip through Authorization header
        let headerValue = bearer.authorizationHeaderValue()
        let parsed = try RFC_6750.Bearer.parse(from: headerValue)
        #expect(parsed.token == longToken)
    }
}
