//
//  Model+Testable.swift
//  AppTests
//
//  Created by Rocky on 2018/6/5.
//

@testable import App
import FluentPostgreSQL

extension User {
    
    static func create(name:String = "Luke",
                       username:String = "lukes",
                       on connection: PostgreSQLConnection) throws -> User {
        
        let user = User(name: name, userName: username)
        
        return try user.save(on: connection).wait()
    }
}

extension Acronym {
    
    static func create(short: String,
                       long: String,
                       user: User? = nil,
                       on connection: PostgreSQLConnection ) throws -> Acronym {
        
        var  acronymsUser = user
        
        if acronymsUser == nil {
            acronymsUser = try User.create(on: connection)
        }
        
        let acronym = Acronym(short: short, long: long, userID: acronymsUser!.id!)
        
        return try acronym.save(on: connection).wait()
    }
}

extension App.Category {
    static func create(name: String = "Random",
                       on connection: PostgreSQLConnection) throws -> App.Category {
        let category = Category(name: name)
        return try category.save(on: connection).wait()
    }
}
