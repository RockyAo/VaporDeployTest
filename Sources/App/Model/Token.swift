//
//  Token.swift
//  App
//
//  Created by Rocky on 2018/6/10.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token: PostgreSQLUUIDModel {}
extension Token: Content {}
extension Token: Migration {}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64URLEncodedString(), userID: user.requireID())
    }
}

extension Token: Authentication.Token {
    typealias UserType = User
    
    static var userIDKey: WritableKeyPath<Token, UUID>  = \Token.userID
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}
