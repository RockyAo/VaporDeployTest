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
    
    init(short:String, long:String) {
        self.short = short
        self.long = long
    }
}

//extension Acronym: Model {
//    typealias Database = SQLiteDatabase
//    typealias ID = Int
//    public static var idKey: IDKey = \Acronym.id
//}

extension Acronym: PostgreSQLModel {}

extension Acronym: Migration {}

extension Acronym: Content {}

extension Acronym: Parameter {}




