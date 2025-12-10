//
//  RFC_6750.swift
//  swift-rfc-6750
//
//  Created by Generated on 2025-07-27.
//

public import Foundation

/// Implementation of RFC 6750: The OAuth 2.0 Authorization Framework: Bearer Token Usage
///
/// See: https://www.rfc-editor.org/rfc/rfc6750.html
public enum RFC_6750 {
    /// Represents an OAuth 2.0 Bearer Token according to RFC 6750
    public struct Bearer: Codable, Hashable, Sendable {
        public let token: String

        /// Creates a Bearer token
        /// - Parameter token: The access token string
        /// - Throws: `Error.invalidToken` if token is invalid
        public init(token: String) throws {
            let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw Error.invalidToken("Token cannot be empty")
            }
            guard trimmed.allSatisfy({ $0.isASCII && !$0.isWhitespace }) else {
                throw Error.invalidToken("Token must contain only ASCII non-whitespace characters")
            }
            self.token = trimmed
        }

        /// Creates a Bearer token without validation (for internal use)
        ///
        /// **Warning**: Bypasses RFC validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, token: String) {
            self.token = token
        }
    }
}

// MARK: - Bearer Token Transmission Methods

extension RFC_6750.Bearer {
    /// Creates Authorization header value using Bearer scheme (recommended method)
    /// - Returns: Complete Authorization header value with "Bearer " prefix
    public func authorizationHeaderValue() -> String {
        return "Bearer \(token)"
    }

    /// Creates form parameter for request body transmission
    /// - Returns: Form parameter name-value pair
    /// - Note: Only use with application/x-www-form-urlencoded content type
    public func formParameter() -> (name: String, value: String) {
        return ("access_token", token)
    }

    /// Creates URI query parameter (not recommended)
    /// - Returns: Query parameter name-value pair
    /// - Warning: This method has security implications and should be avoided
    public func queryParameter() -> (name: String, value: String) {
        return ("access_token", token)
    }

    /// Parses Bearer token from Authorization header value
    /// - Parameter headerValue: The Authorization header value
    /// - Returns: Bearer token if valid
    /// - Throws: `Error` for invalid format
    public static func parse(from headerValue: String) throws -> RFC_6750.Bearer {
        let trimmed = headerValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.lowercased().hasPrefix("bearer ") else {
            throw Error.invalidRequest("Authorization header must start with 'Bearer '")
        }

        let tokenString = String(trimmed.dropFirst(7))
        guard !tokenString.isEmpty else {
            throw Error.invalidToken("Bearer token cannot be empty")
        }

        return RFC_6750.Bearer(__unchecked: (), token: tokenString)
    }

    /// Parses Bearer token from form parameter
    /// - Parameter parameters: Form parameters dictionary
    /// - Returns: Bearer token if present and valid
    /// - Throws: `Error` for missing or invalid token
    public static func parse(
        fromFormParameters parameters: [String: String]
    ) throws -> RFC_6750.Bearer {
        guard let tokenString = parameters["access_token"] else {
            throw Error.invalidRequest("access_token parameter is required")
        }

        guard !tokenString.isEmpty else {
            throw Error.invalidToken("Bearer token cannot be empty")
        }

        return RFC_6750.Bearer(__unchecked: (), token: tokenString)
    }

    /// Parses Bearer token from URI query parameter
    /// - Parameter queryItems: URL query items
    /// - Returns: Bearer token if present and valid
    /// - Throws: `Error` for missing or invalid token
    public static func parse(fromQueryItems queryItems: [URLQueryItem]) throws -> RFC_6750.Bearer {
        guard let tokenItem = queryItems.first(where: { $0.name == "access_token" }),
            let tokenString = tokenItem.value
        else {
            throw Error.invalidRequest("access_token query parameter is required")
        }

        guard !tokenString.isEmpty else {
            throw Error.invalidToken("Bearer token cannot be empty")
        }

        return RFC_6750.Bearer(__unchecked: (), token: tokenString)
    }
}

// MARK: - WWW-Authenticate Challenge

extension RFC_6750.Bearer {
    /// Represents a Bearer token authentication challenge from WWW-Authenticate header
    public struct Challenge: Codable, Hashable, Sendable {
        public let realm: String?
        public let scope: String?
        public let error: ErrorCode?
        public let errorDescription: String?

        /// Creates a Bearer authentication challenge
        /// - Parameters:
        ///   - realm: Optional protection space identifier
        ///   - scope: Optional space-delimited list of required access scopes
        ///   - error: Optional error code for access denial
        ///   - errorDescription: Optional human-readable error explanation
        public init(
            realm: String? = nil,
            scope: String? = nil,
            error: ErrorCode? = nil,
            errorDescription: String? = nil
        ) {
            self.realm = realm
            self.scope = scope
            self.error = error
            self.errorDescription = errorDescription
        }

        /// Creates WWW-Authenticate header value
        /// - Returns: Complete WWW-Authenticate header value
        public func wwwAuthenticateHeaderValue() -> String {
            var components: [String] = ["Bearer"]

            if let realm = realm {
                components.append("realm=\"\(realm)\"")
            }

            if let scope = scope {
                components.append("scope=\"\(scope)\"")
            }

            if let error = error {
                components.append("error=\"\(error.rawValue)\"")
            }

            if let errorDescription = errorDescription {
                components.append("error_description=\"\(errorDescription)\"")
            }

            return components.joined(separator: ", ")
        }

        /// Parses Bearer challenge from WWW-Authenticate header
        /// - Parameter headerValue: The WWW-Authenticate header value
        /// - Returns: Bearer.Challenge if valid
        /// - Throws: `Error` for invalid format
        public static func parse(from headerValue: String) throws -> RFC_6750.Bearer.Challenge {
            let trimmed = headerValue.trimmingCharacters(in: .whitespacesAndNewlines)

            guard trimmed.lowercased().hasPrefix("bearer") else {
                throw Error.invalidRequest("WWW-Authenticate header must start with 'Bearer'")
            }

            let parameters = String(trimmed.dropFirst(6)).trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            var realm: String?
            var scope: String?
            var error: ErrorCode?
            var errorDescription: String?

            if !parameters.isEmpty {
                let components = parameters.components(separatedBy: ",")
                for component in components {
                    let trimmedComponent = component.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmedComponent.lowercased().hasPrefix("realm=") {
                        realm = extractQuotedValue(from: trimmedComponent, parameter: "realm")
                    } else if trimmedComponent.lowercased().hasPrefix("scope=") {
                        scope = extractQuotedValue(from: trimmedComponent, parameter: "scope")
                    } else if trimmedComponent.lowercased().hasPrefix("error=") {
                        if let errorValue = extractQuotedValue(
                            from: trimmedComponent,
                            parameter: "error"
                        ) {
                            error = ErrorCode(rawValue: errorValue)
                        }
                    } else if trimmedComponent.lowercased().hasPrefix("error_description=") {
                        errorDescription = extractQuotedValue(
                            from: trimmedComponent,
                            parameter: "error_description"
                        )
                    }
                }
            }

            return RFC_6750.Bearer.Challenge(
                realm: realm,
                scope: scope,
                error: error,
                errorDescription: errorDescription
            )
        }

        private static func extractQuotedValue(from component: String, parameter: String) -> String?
        {
            let prefix = "\(parameter)="
            guard component.lowercased().hasPrefix(prefix.lowercased()) else { return nil }

            let value = String(component.dropFirst(prefix.count)).trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            if value.hasPrefix("\"") && value.hasSuffix("\"") {
                return String(value.dropFirst().dropLast())
            }
            return value
        }
    }
}

// MARK: - Error Handling

extension RFC_6750.Bearer {
    /// OAuth 2.0 Bearer Token error codes according to RFC 6750
    public enum ErrorCode: String, Codable, Hashable, Sendable, CaseIterable {
        case invalidRequest = "invalid_request"
        case invalidToken = "invalid_token"
        case insufficientScope = "insufficient_scope"

        public var description: String {
            switch self {
            case .invalidRequest:
                return
                    "The request is missing a required parameter, includes an unsupported parameter or parameter value, repeats the same parameter, uses more than one method for including an access token, or is otherwise malformed."
            case .invalidToken:
                return
                    "The access token provided is expired, revoked, malformed, or invalid for other reasons."
            case .insufficientScope:
                return "The request requires higher privileges than provided by the access token."
            }
        }
    }

    /// Errors that can occur during Bearer token operations
    public enum Error: Swift.Error, Sendable, Equatable {
        case invalidRequest(String)
        case invalidToken(String)
        case insufficientScope(String)

        public var errorCode: ErrorCode {
            switch self {
            case .invalidRequest:
                return .invalidRequest
            case .invalidToken:
                return .invalidToken
            case .insufficientScope:
                return .insufficientScope
            }
        }
    }
}

extension RFC_6750.Bearer.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .invalidToken(let message):
            return "Invalid token: \(message)"
        case .insufficientScope(let message):
            return "Insufficient scope: \(message)"
        }
    }
}

extension RFC_6750.Bearer.Error: LocalizedError {
    public var errorDescription: String? {
        description
    }
}
