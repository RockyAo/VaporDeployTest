//
//  User.swift
//  App
//
//  Created by Rocky on 2018/5/31.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var userName: String
    var password: String
    
    init(name: String, userName: String, password: String) {
        self.name = name
        self.userName = userName
        self.password = password
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var userName: String
        
        init(id: UUID?,name: String, userName: String) {
            self.id = id
            self.name = name
            self.userName = userName
        }
    }
}

extension User: PostgreSQLUUIDModel {}

extension User: Content {}
extension User.Public: Content {}

extension User: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            try builder.addIndex(to: \.userName, isUnique: true)
        })
    }
}

extension User: Parameter {}

extension User {
  
    func converToPublic() -> User.Public {
        return User.Public(id: id, name: name, userName: userName)
    }
    
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}

extension User: BasicAuthenticatable {
    
    static var usernameKey: WritableKeyPath<User, String> = \User.userName
    
    static var passwordKey: WritableKeyPath<User, String> = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}

extension Future where T: User {
    
    func converToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self, { user in
            return user.converToPublic()
        })
    }
}

struct AdminUser: Migration {
   
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let password = try? BCrypt.hash("password")
        guard let hasedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "Admin", userName: "admin", password: hasedPassword)
        return user.save(on: connection).transform(to: ())
    }
    
    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return .done(on: connection)
    }
}





