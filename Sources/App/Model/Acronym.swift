//
//  Acronym.swift
//  App
//
//  Created by Rocky on 2018/5/30.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class Acronym: Codable {
    var id:Int?
    var short:String
    var long:String
    var userID: User.ID
    
    init(short:String,long:String,userID:User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension Acronym: PostgreSQLModel {}

extension Acronym: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            try builder.addReference(from: \.userID, to: \User.id)
        })
    }
}

extension Acronym: Content {}

extension Acronym: Parameter {}

extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
}








